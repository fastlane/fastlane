module Fastlane
  module Actions
    module SharedValues
    end

    class GitBranchAction < Action
      def self.run(params)
        branch = `git symbolic-ref HEAD --short 2>/dev/null`.strip
        return branch unless branch.empty?
        %w(GIT_BRANCH BRANCH_NAME TRAVIS_BRANCH BITRISE_GIT_BRANCH CI_BUILD_REF_NAME)
          .map { |env_var|
            FastlaneCore::Env.truthy?(env_var) ? ENV[env_var] : nil
          }
          .compact
          .first
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
