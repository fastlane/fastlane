module Fastlane
  module Actions
    module SharedValues
    end

    class GitBranchAction < Action
      def self.run(params)
        ENV['GIT_BRANCH'] or `git symbolic-ref HEAD --short 2>/dev/null`.strip
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
    end
  end
end
