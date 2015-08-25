module Fastlane
  module Actions
    class LastGitTagAction < Action
      def self.run(params)
        sh "git describe --tags --abbrev=0"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get the most recent git tag"
      end

      def self.available_options
        []
      end

      def self.output
        []
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
