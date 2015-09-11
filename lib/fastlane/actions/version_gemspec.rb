module Fastlane
  module Actions
    module SharedValues
      GEMSPEC_VERSION_NUMBER = :GEMSPEC_VERSION_NUMBER
    end

    class VersionGemspecFile
      attr_accessor :path
      attr_accessor :gemspec_content
      attr_accessor :version_regex
      attr_accessor :version_match
      attr_accessor :version_value

      def initialize(path = nil)
        version_var_name = 'version'
        @version_regex = /^(?<begin>[^#]*#{version_var_name}\s*=\s*['"])(?<value>(?<major>[0-9]+)(\.(?<minor>[0-9]+))?(\.(?<patch>[0-9]+))?)(?<end>['"])/i

        return unless (path || '').length > 0
        raise "Could not find gemspec file at path '#{path}'".red unless File.exist?(path)

        @path = File.expand_path(path)
        gemspec_content = File.read(path)

        parse(gemspec_content)
      end

      def parse(gemspec_content)
        @gemspec_content = gemspec_content
        @version_match = @version_regex.match(@gemspec_content)
        raise "Could not find version in gemspec content '#{@gemspec_content}'".red if @version_match.nil?
        @version_value = @version_match[:value]
      end

      def bump_version(bump_type)
        major = version_match[:major].to_i
        minor = version_match[:minor].to_i || 0
        patch = version_match[:patch].to_i || 0

        case bump_type
        when 'patch'
          patch += 1
        when 'minor'
          minor += 1
          patch = 0
        when 'major'
          major += 1
          minor = 0
          patch = 0
        end

        @version_value = "#{major}.#{minor}.#{patch}"
      end

      def update_gemspec(version = nil)
        new_version = version || @version_value
        updated_gemspec_content = @gemspec_content.gsub(@version_regex, "#{@version_match[:begin]}#{new_version}#{@version_match[:end]}")

        File.open(gemspec_path, "w") {|file| file.puts updated_gemspec_content} unless Helper.test?

        updated_gemspec_content
      end
    end

    class VersionGetGemspecAction < Action
      def self.run(params)
        gemspec_path = params[:path]

        raise "Could not find gemspec file at path '#{gemspec_path}'".red unless File.exist? gemspec_path

        version_gemspec_file = VersionGemspecFile.new(gemspec_path)

        Actions.lane_context[SharedValues::GEMSPEC_VERSION_NUMBER] = version_gemspec_file.version_value
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get the version in a gemspec file"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_VERSION_GEMSPEC_PATH",
                                       description: "You must specify the path to the gemspec file",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         raise "Please pass a path to the `version_get_gemspec` action".red if value.length == 0
                                       end)
        ]
      end

      def self.output
        [
          ['GEMSPEC_VERSION_NUMBER', 'The gemspec version number']
        ]
      end

      def self.authors
        ["Liquidsoul"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end

    class VersionBumpGemspecAction < Action
      def self.run(params)
        gemspec_path = params[:path]

        raise "Could not find gemspec file at path #{gemspec_path}".red unless File.exist? gemspec_path

        version_gemspec_file = VersionGemspecFile.new(gemspec_path)

        if params[:version_number]
          new_version = params[:version_number]
        else
          new_version = version_gemspec_file.bump_version(params[:bump_type])
        end

        version_gemspec_file.update_gemspec(new_version)

        Actions.lane_context[SharedValues::GEMSPEC_VERSION_NUMBER] = new_version
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Increment or set the version in a gemspec file"
      end

      def self.details
        [
          "You can use this action to manipulate any 'version' variable contained in a ruby file.",
          "For example, you can use it to bump the version of a cocoapods' podspec file."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_VERSION_BUMP_GEMSPEC_PATH",
                                       description: "You must specify the path to the gemspec file to update",
                                       verify_block: proc do |value|
                                         raise "Please pass a path to the `version_bump_gemspec` action".red if value.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :bump_type,
                                       env_name: "FL_VERSION_BUMP_GEMSPEC_BUMP_TYPE",
                                       description: "The type of this version bump. Available: patch, minor, major",
                                       default_value: "patch",
                                       verify_block: proc do |value|
                                         raise "Available values are 'patch', 'minor' and 'major'" unless ['patch', 'minor', 'major'].include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :version_number,
                                       env_name: "FL_VERSION_BUMP_GEMSPEC_VERSION_NUMBER",
                                       description: "Change to a specific version. This will replace the bump type value",
                                       optional: true)
        ]
      end

      def self.output
        [
          ['GEMSPEC_VERSION_NUMBER', 'The new gemspec version number']
        ]
      end

      def self.authors
        ["Liquidsoul"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
