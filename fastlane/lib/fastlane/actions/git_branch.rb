module Fastlane
  module Actions
    class GitBranchAction < Action
      def self.run(params)
        branch = Actions.git_branch_using_ci_env || ""
        return "" if branch == "HEAD" # Backwards compatibility with the original (and documented) implementation
        branch
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns the name of the current git branch, possibly as managed by CI ENV variables"
      end

      def self.details
        [
          "If no branch found, this action will return an empty string. This is a wrapper for the internal action Actions.git_branch",
          "Note: This action is managed by CI ENV means it will always returns same git branch name even if you switch branches over the CI in a single job"
        ].join("\n")
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

      def self.example_code
        [
          'git_branch'
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
