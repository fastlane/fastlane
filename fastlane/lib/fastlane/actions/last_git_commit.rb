module Fastlane
  module Actions
    class LastGitCommitAction < Action
      def self.run(params)
        Actions.last_git_commit_dict
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Return last git commit hash, abbreviated commit hash, commit message and author"
      end

      def self.return_value
        "Returns the following dict: {commit_hash: \"commit hash\", abbreviated_commit_hash: \"abbreviated commit hash\" author: \"Author\", message: \"commit message\"}"
      end

      def self.author
        "ngutman"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
