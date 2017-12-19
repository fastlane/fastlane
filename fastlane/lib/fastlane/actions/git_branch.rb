module Fastlane
  module Actions
    module SharedValues
      GIT_BRANCH_ENV_VARS = %w(GIT_BRANCH BRANCH_NAME TRAVIS_BRANCH BITRISE_GIT_BRANCH CI_BUILD_REF_NAME CI_COMMIT_REF_NAME WERCKER_GIT_BRANCH BUILDKITE_BRANCH).freeze
    end

    class GitBranchAction < Action
      def self.run(params)
        env_name = SharedValues::GIT_BRANCH_ENV_VARS.find { |env_var| FastlaneCore::Env.truthy?(env_var) }
        ENV.fetch(env_name.to_s) { `git symbolic-ref HEAD --short 2>/dev/null`.strip }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns the name of the current git branch, possibly as managed by CI ENV vars"
      end

      def self.details
        "If no branch could be found, this action will return an empty string"
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
