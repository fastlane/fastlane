module Fastlane
  module Actions
    class GitBranchAction < Action
      def self.run(params)
        branch = Actions.git_branch || ""
        return "" if branch == "HEAD" # Backwards compatibility with the original (and documented) implementation
        branch
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns the name of the current git branch, possibly as managed by CI ENV vars"
      end

      def self.details
        "If no branch could be found, this action will return an empty string. If `FL_GIT_BRANCH_DONT_USE_ENV_VARS` is `true`, it'll ignore CI ENV vars. This is a wrapper for the internal action Actions.git_branch"
      end

      def self.available_options
        []
      end

      def self.output
        [
          ['GIT_BRANCH_ENV_VARS', 'The git branch environment variables']
        ]
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
