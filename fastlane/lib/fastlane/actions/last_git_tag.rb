module Fastlane
  module Actions
    class LastGitTagAction < Action
      def self.run(params)
        Actions.last_git_tag_name(true, params[:pattern])
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get the most recent git tag"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :pattern,
                                       description: "Pattern to filter tags when looking for last one. Limit tags to ones matching given shell glob. If pattern lacks ?, *, or [, * at the end is implied",
                                       default_value: nil,
                                       optional: true)
        ]
      end

      def self.output
        []
      end

      def self.return_type
        :string
      end

      def self.authors
        ["KrauseFx", "wedkarz"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.details
        [
          "If you are using this action on a **shallow clone**, *the default with some CI systems like Bamboo*, you need to ensure that you have also pulled all the git tags appropriately. Assuming your git repo has the correct remote set you can issue `sh('git fetch --tags')`.",
          "Pattern parameter allows you to filter to a subset of tags."
        ].join("\n")
      end

      def self.example_code
        [
          'last_git_tag',
          'last_git_tag(pattern: "release/v1.0/")'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
