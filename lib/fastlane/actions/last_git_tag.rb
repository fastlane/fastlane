module Fastlane
  module Actions
    class LastGitTagAction < Action
      def self.run(params)
        Actions.last_git_tag_name
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
