module Fastlane
  module Actions
    class GitDefaultRemoteBranchAction < Action
      def self.run(params)
        Actions.git_default_remote_branch_name || ""
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns the name of the current git remote default branch"
      end

      def self.details
        "If no default remote branch could be found, this action will return an empty string. This is a wrapper for the internal action Actions.git_default_remote_branch_name"
      end

      def self.available_options
        []
      end

      def self.output
        []
      end

      def self.authors
        ["SeanMcNeil"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'git_default_remote_branch'
        ]
      end

      def self.return_type
        :string
      end

      def self.category
        :source_control
      end
    end
  end
end
