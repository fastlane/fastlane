module Fastlane
  module Actions
    class LastGitCommitAction < Action
      def self.run(params)
        message = sh "git log -1 --pretty=%B"
        author = sh "git log -1 --pretty=%an"

        {author: author, message: message}
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Return last git commit message and author"
      end

      def self.return_value
        "Returns the following dict: {author: \"Author\", message: \"commit message\"}"
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
