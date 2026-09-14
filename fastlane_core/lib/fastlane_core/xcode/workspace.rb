require 'pathname'
require 'rexml/document'
require_relative 'error'
require_relative 'project'

module FastlaneCore
  module Xcode
    # Reads the `contents.xcworkspacedata` of an `.xcworkspace` to find the projects it
    # contains and the schemes they (and the workspace itself) share.
    class Workspace
      class FileReference
        # @return [String] path as written in the workspace, with parent group paths prepended
        attr_reader :path

        # @return [String] `group`, `container`, `self`, `absolute` or `developer`
        attr_reader :type

        def initialize(path, type = 'group')
          @path = Pathname.new(path.to_s).cleanpath.to_s
          @type = type.to_s
        end

        # @param workspace_dir_path [String] the directory *containing* the `.xcworkspace`
        def absolute_path(workspace_dir_path)
          case type
          when 'group', 'container', 'self'
            File.expand_path(File.join(workspace_dir_path.to_s, path))
          when 'absolute'
            File.expand_path(path)
          when 'developer'
            raise Error, "Developer workspace file reference type is not yet supported (#{path})"
          else
            raise Error, "Unsupported workspace file reference type `#{type}`"
          end
        end

        def ==(other)
          other.kind_of?(FileReference) && path == other.path && type == other.type
        end
        alias eql? ==

        def hash
          [path, type].hash
        end
      end

      # @return [String] absolute path of the `.xcworkspace` bundle
      attr_reader :path

      # @return [Array<FileReference>] every file referenced by the workspace, projects and loose files alike
      attr_reader :file_references

      # @return [Hash{String => String}] scheme name => absolute path of the `.xcodeproj` (or of the
      #   `.xcworkspace` for schemes stored in the workspace) that defines it
      attr_reader :schemes

      def self.open(path)
        new(path)
      end

      def initialize(path)
        @path = File.expand_path(path.to_s)
        @file_references = read_file_references
        @schemes = load_schemes
      end

      # @return [Array<String>] absolute paths of the `.xcodeproj` bundles in the workspace
      def project_paths
        workspace_dir = File.dirname(path)
        file_references.map { |reference| reference.absolute_path(workspace_dir) }.select { |p| p.end_with?('.xcodeproj') }
      end

      private

      def read_file_references
        contents_path = File.join(path, 'contents.xcworkspacedata')
        return [] unless File.exist?(contents_path)

        document = REXML::Document.new(File.read(contents_path))
        REXML::XPath.match(document, '/Workspace//FileRef').map do |node|
          type, location = node.attributes['location'].to_s.split(':', 2)
          location = prepend_parent_path(node, location) if type == 'group'
          FileReference.new(location, type)
        end
      end

      # A `group:` location is relative to the enclosing `<Group>` elements
      def prepend_parent_path(node, location)
        parent = node.parent
        return location unless parent.kind_of?(REXML::Element) && parent.name == 'Group'

        parent_location = group_location(parent)
        return location if parent_location.nil? || parent_location.empty?
        File.join(parent_location, location.to_s)
      end

      def group_location(group_node)
        type, location = group_node.attributes['location'].to_s.split(':', 2)
        location ||= ''
        location = prepend_parent_path(group_node, location) if type == 'group'
        location
      end

      def load_schemes
        schemes = {}
        project_paths.each do |project_path|
          Project.schemes(project_path).each { |name| schemes[name] = project_path }
        end
        Dir[File.join(path, 'xcshareddata', 'xcschemes', '*.xcscheme')].each do |scheme|
          schemes[File.basename(scheme, '.xcscheme')] = path
        end
        schemes
      end
    end
  end
end
