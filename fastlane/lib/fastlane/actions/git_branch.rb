module Fastlane
  module Actions
    module SharedValues
    end

    class GitBranchAction < Action
      def self.run(params)
        return ENV['GIT_BRANCH'] if ENV['GIT_BRANCH']
        return ENV["TRAVIS_BRANCH"] if ENV["TRAVIS_BRANCH"]
        return ENV["BITRISE_GIT_BRANCH"] if ENV["BITRISE_GIT_BRANCH"]
        `git symbolic-ref HEAD --short 2>/dev/null`.strip
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
