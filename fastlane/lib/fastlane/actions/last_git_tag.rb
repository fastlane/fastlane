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

      def self.return_type
        :string
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.details
        "If you are using this action on a **shallow clone**, *the default with some CI systems like Bamboo*, you need to ensure that you have also have pulled all the git tags appropriately. Assuming your git repo has the correct remote set you can issue `sh('git fetch --tags')`"
      end

      def self.example_code
        [
          'last_git_tag'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
