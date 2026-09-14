require 'pathname'
require_relative 'error'
require_relative 'plist'
require_relative 'xcconfig'

module FastlaneCore
  module Xcode
    # A read-only model of an Xcode project, built from a plain parse of its
    # `project.pbxproj`. It covers what fastlane needs to *inspect* a project (targets,
    # build configurations, resolved build settings, file paths) without loading the
    # Xcodeproj gem. Anything that modifies a project still goes through Xcodeproj.
    class Project
      INHERITED_KEYWORDS = ['$(inherited)', '${inherited}'].freeze
      INHERITED_REGEXP = Regexp.union(INHERITED_KEYWORDS)

      # @return [String] absolute path of the `.xcodeproj` bundle
      attr_reader :path

      # @return [String] absolute path of the directory containing the `.xcodeproj`
      attr_reader :project_dir

      # @return [RootObject] the `PBXProject` object
      attr_reader :root_object

      def self.open(path)
        new(path)
      end

      # Names of the shared schemes of the project at `project_path`. Falls back to the
      # project name when there are none, which is the scheme Xcode itself would offer.
      def self.schemes(project_path)
        schemes = Dir[File.join(project_path, 'xcshareddata', 'xcschemes', '*.xcscheme')].map do |scheme|
          File.basename(scheme, '.xcscheme')
        end
        schemes << File.basename(project_path, '.xcodeproj') if schemes.empty?
        schemes
      end

      def initialize(path)
        @path = File.expand_path(path.to_s)
        pbxproj = File.join(@path, 'project.pbxproj')
        raise Error, "Unable to open `#{@path}` because it doesn't exist." unless File.exist?(pbxproj)

        @project_dir = File.dirname(@path)
        plist = Plist.read_from_path(pbxproj)
        raise Error, "`#{pbxproj}` is not a valid Xcode project file." unless plist.kind_of?(Hash) && plist['objects'].kind_of?(Hash)

        @raw_objects = plist['objects']
        @objects = {}
        @root_object = object(plist['rootObject'])
        raise Error, "`#{pbxproj}` has no root object." unless @root_object.kind_of?(RootObject)
      end

      # @return [Array<Object>] every object in the project file
      def objects
        @raw_objects.keys.map { |uuid| object(uuid) }
      end

      # @return [Object, nil] the object with the given UUID
      def object(uuid)
        return nil if uuid.nil?
        @objects[uuid] ||= begin
          attributes = @raw_objects[uuid]
          attributes.kind_of?(Hash) ? class_for_isa(attributes['isa']).new(self, uuid, attributes) : nil
        end
      end

      # @return [Array<Target>] all targets, in the order Xcode lists them
      def targets
        root_object.targets
      end

      # @return [Array<Target>] only the `PBXNativeTarget`s
      def native_targets
        targets.select(&:native?)
      end

      # @return [ConfigurationList] the project-level build configuration list
      def build_configuration_list
        root_object.build_configuration_list
      end

      # @return [Array<BuildConfiguration>] the project-level build configurations
      def build_configurations
        build_configuration_list ? build_configuration_list.build_configurations : []
      end

      # @return [Array<FileReference>] every `PBXFileReference` in the project
      def files
        objects.grep(FileReference)
      end

      # @return [Object, nil] the group (or the `PBXProject` for the main group) that contains the object
      def parent_of(uuid)
        @parents ||= begin
          parents = {}
          @raw_objects.each do |parent_uuid, attributes|
            children = attributes['children']
            next unless children.kind_of?(Array)
            children.each { |child| parents[child] = parent_uuid }
          end
          parents[root_object['mainGroup']] = root_object.uuid if root_object['mainGroup']
          parents
        end
        object(@parents[uuid])
      end

      private

      def class_for_isa(isa)
        case isa
        when 'PBXProject' then RootObject
        when 'PBXNativeTarget', 'PBXAggregateTarget', 'PBXLegacyTarget' then Target
        when 'XCConfigurationList' then ConfigurationList
        when 'XCBuildConfiguration' then BuildConfiguration
        when 'PBXFileReference' then FileReference
        when 'PBXGroup', 'PBXVariantGroup', 'XCVersionGroup', 'PBXFileSystemSynchronizedRootGroup' then Group
        else Object
        end
      end

      # Base class for every entry of the `objects` dictionary
      class Object
        attr_reader :project, :uuid

        def initialize(project, uuid, attributes)
          @project = project
          @uuid = uuid
          @attributes = attributes
        end

        def isa
          @attributes['isa']
        end

        # @return [Object, nil] raw attribute value, with object references left as UUID strings
        def [](key)
          @attributes[key]
        end

        # @return [Hash] the raw attributes as stored in the pbxproj
        def to_hash
          @attributes
        end

        def inspect
          "#<#{self.class.name} #{uuid} #{isa}>"
        end
      end

      # The `PBXProject` object
      class RootObject < Object
        # @return [Hash] the project attributes, e.g. `TargetAttributes` and `LastUpgradeCheck`
        def attributes
          self['attributes'].kind_of?(Hash) ? self['attributes'] : {}
        end

        def targets
          Array(self['targets']).map { |uuid| project.object(uuid) }.grep(Target)
        end

        def build_configuration_list
          project.object(self['buildConfigurationList'])
        end

        def main_group
          project.object(self['mainGroup'])
        end

        # @return [String] path of the source root relative to the project directory, usually empty
        def project_dir_path
          self['projectDirPath'].to_s
        end
      end

      class ConfigurationList < Object
        def build_configurations
          Array(self['buildConfigurations']).map { |uuid| project.object(uuid) }.grep(BuildConfiguration)
        end

        # @return [BuildConfiguration, nil] the configuration with the given name
        def build_configuration(name)
          build_configurations.find { |configuration| configuration.name == name }
        end

        # @return [Hash{String => Object}] the value of a setting for each configuration, keyed by name
        def get_setting(key, resolve_against_xcconfig = false, root_target = nil)
          build_configurations.each_with_object({}) do |configuration, result|
            result[configuration.name] = if resolve_against_xcconfig
                                           configuration.resolve_build_setting(key, root_target)
                                         else
                                           configuration.build_settings[key]
                                         end
          end
        end
      end

      # A `PBXNativeTarget`, `PBXAggregateTarget` or `PBXLegacyTarget`
      class Target < Object
        TEST_PRODUCT_TYPES = [
          'com.apple.product-type.bundle.unit-test',
          'com.apple.product-type.bundle.ui-testing'
        ].freeze

        def name
          self['name']
        end

        def product_type
          self['productType']
        end

        def native?
          isa == 'PBXNativeTarget'
        end

        def test_target_type?
          TEST_PRODUCT_TYPES.include?(product_type)
        end

        def build_configuration_list
          project.object(self['buildConfigurationList'])
        end

        def build_configurations
          build_configuration_list ? build_configuration_list.build_configurations : []
        end

        # @return [BuildConfiguration, nil] this target's configuration with the given name
        def build_configuration(name)
          build_configurations.find { |configuration| configuration.name == name }
        end

        # The value of a build setting for each configuration, keyed by configuration name.
        # Target-level values win over project-level ones, and `$(inherited)` in a target
        # value is replaced by the project value.
        #
        # @param resolve_against_xcconfig [Boolean] when true, also expands variables and
        #   consults the base `.xcconfig` files instead of returning the raw values
        def resolved_build_setting(key, resolve_against_xcconfig = false)
          target_settings = build_configuration_list ? build_configuration_list.get_setting(key, resolve_against_xcconfig, self) : {}
          project_settings = project.build_configuration_list ? project.build_configuration_list.get_setting(key, resolve_against_xcconfig) : {}
          target_settings.merge(project_settings) do |_key, target_value, project_value|
            target_includes_inherited = target_value && INHERITED_KEYWORDS.any? { |keyword| target_value.include?(keyword) }
            if target_includes_inherited && project_value
              if target_value.kind_of?(String)
                target_value.gsub(INHERITED_REGEXP, project_value)
              else
                target_value.flat_map { |value| INHERITED_KEYWORDS.include?(value) ? project_value : value }
              end
            else
              target_value || project_value
            end
          end
        end
      end

      # An `XCBuildConfiguration`
      class BuildConfiguration < Object
        MUTUAL_RECURSION_SENTINEL = 'fastlane_core.xcode.mutual_recursion_sentinel'.freeze
        VARIABLE_REFERENCE = /\$(?:\{([_a-zA-Z0-9]+?)\}|\(([_a-zA-Z0-9]+?)\))/

        def name
          self['name']
        end

        # @return [Hash] the raw build settings of this configuration
        def build_settings
          self['buildSettings'].kind_of?(Hash) ? self['buildSettings'] : {}
        end

        # @return [FileReference, nil] the base `.xcconfig` file of this configuration
        def base_configuration_reference
          project.object(self['baseConfigurationReference'])
        end

        # @return [Hash] the flattened contents of the base `.xcconfig` file, if any
        def xcconfig
          @xcconfig ||= begin
            reference = base_configuration_reference
            reference && File.exist?(reference.real_path) ? Xcconfig.load(reference.real_path) : {}
          end
        end

        def project_level?
          project.build_configurations.any? { |configuration| configuration.uuid == uuid }
        end

        # Resolves a build setting the way Xcode would: project settings are inherited by the
        # target, the base xcconfig sits between them, `$(inherited)` and `$(VARIABLE)`
        # references are expanded, and an environment variable of the same name wins.
        #
        # @param root_target [Target, nil] the target whose configuration of the same name
        #   variable references should be resolved against (pass the owning target)
        def resolve_build_setting(key, root_target = nil, previous_key = nil)
          setting = resolve_variable_substitution(key, build_settings[key], root_target, previous_key)
          config_setting = resolve_variable_substitution(key, xcconfig[key], root_target, previous_key)

          project_setting = nil
          unless project_level?
            project_configuration = project.build_configuration_list && project.build_configuration_list.build_configuration(name)
            project_setting = project_configuration.resolve_build_setting(key, root_target) if project_configuration
          end

          defaults = {
            'CONFIGURATION' => name,
            'SRCROOT' => project.project_dir
          }

          setting = nil if previous_key.nil? && setting == MUTUAL_RECURSION_SENTINEL

          [defaults[key], project_setting, config_setting, setting, ENV[key]].compact.reduce(nil) do |inherited, value|
            expand_build_setting(value, inherited)
          end
        end

        private

        def expand_build_setting(value, inherited)
          if value.kind_of?(Array) && inherited.kind_of?(String)
            inherited = split_build_setting_array_to_string(inherited)
          elsif value.kind_of?(String) && inherited.kind_of?(Array)
            value = split_build_setting_array_to_string(value)
          end

          inherited ||= value.kind_of?(String) ? '' : []
          return value.gsub(INHERITED_REGEXP, inherited) if value.kind_of?(String)
          value.flat_map { |element| INHERITED_KEYWORDS.include?(element) ? inherited : element }
        end

        def split_build_setting_array_to_string(string)
          string.scan(/ *((['"]?).*?[^\\]\2)(?=( |\z))/).map(&:first)
        end

        def resolve_variable_substitution(key, value, root_target, previous_key = nil)
          case value
          when Array
            return value.map { |element| resolve_variable_substitution(key, element, root_target) }
          when nil
            return nil
          when String
            nil
          else
            raise ArgumentError, "Build setting values can only be nil, a string or an array, got #{value.inspect} for #{key}"
          end

          match = value.match(VARIABLE_REFERENCE)
          return value unless match

          variable_reference = match[0]
          variable = match[1] || match[2]
          case variable
          when 'inherited'
            # handled by expand_build_setting once every other reference is resolved
            value
          when key
            nil # prevents infinite recursion
          when previous_key
            MUTUAL_RECURSION_SENTINEL
          else
            configuration = (root_target && root_target.build_configuration(name)) || self
            resolved = configuration.resolve_build_setting(variable, root_target, key) || ''
            return MUTUAL_RECURSION_SENTINEL if resolved == MUTUAL_RECURSION_SENTINEL

            resolved = resolved.join(' ') if resolved.kind_of?(Array)
            resolve_variable_substitution(key, value.gsub(variable_reference, resolved), root_target)
          end
        end
      end

      # Shared by file references and groups: anything with a `path` and a `sourceTree`
      class PathObject < Object
        def path
          self['path']
        end

        def name
          self['name']
        end

        def source_tree
          self['sourceTree']
        end

        def display_name
          name || (path && File.basename(path))
        end

        # @return [String] the absolute path of the file or group on disk. Source trees that
        #   only Xcode can resolve (`BUILT_PRODUCTS_DIR`, `SDKROOT`, ...) are kept as `${NAME}`.
        def real_path
          base = source_tree_real_path
          relative = path || ''
          (base ? Pathname.new(base) + relative : Pathname.new(relative)).to_s
        end

        private

        def source_tree_real_path
          case source_tree
          when '<group>'
            parent = project.parent_of(uuid)
            if parent.nil? || parent.isa == 'PBXProject'
              (Pathname.new(project.project_dir) + project.root_object.project_dir_path).to_s
            else
              parent.real_path
            end
          when 'SOURCE_ROOT'
            project.project_dir
          when '<absolute>'
            nil
          else
            "${#{source_tree}}"
          end
        end
      end

      # A `PBXFileReference`
      class FileReference < PathObject
      end

      # A `PBXGroup`, `PBXVariantGroup`, `XCVersionGroup` or `PBXFileSystemSynchronizedRootGroup`
      class Group < PathObject
        def children
          Array(self['children']).map { |uuid| project.object(uuid) }.compact
        end
      end
    end
  end
end
