module Fastlane
  module Actions
    module SharedValues
    end

    class GitBranchAction < Action
      def self.run(params)
        env_vars = %w(GIT_BRANCH BRANCH_NAME TRAVIS_BRANCH BITRISE_GIT_BRANCH CI_BUILD_REF_NAME)
        env_name = env_vars.find { |env_var| FastlaneCore::Env.truthy?(env_var) }
        ENV.fetch(env_name.to_s) { `git symbolic-ref HEAD --short 2>/dev/null`.strip }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns the name of the current git branch"
      end

      def self.details
        "If no branch could be found, this action will return nil"
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

      def self.category
        :source_control
      end
    end
  end
end
