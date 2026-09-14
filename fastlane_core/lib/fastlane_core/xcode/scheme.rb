require 'rexml/document'

module FastlaneCore
  module Xcode
    # Reads an `.xcscheme` file
    class Scheme
      attr_reader :path

      def initialize(path)
        @path = path.to_s
        @document = REXML::Document.new(File.read(@path))
      end

      # @return [String, nil] the build configuration used by the Archive action, `Release`
      #   when the scheme has no Archive action at all (Xcode's default)
      def archive_build_configuration
        action = REXML::XPath.first(@document, '/Scheme/ArchiveAction')
        return 'Release' unless action
        action.attributes['buildConfiguration']
      end
    end
  end
end
