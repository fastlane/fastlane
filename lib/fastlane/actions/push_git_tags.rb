module Fastlane
  module Actions
    class PushGitTagsAction < Action
      def self.run(params)
        command = [
          'git',
          'push',
          '--tags'
        ]

        result = Actions.sh(command.join(' '))
        Helper.log.info 'Tags pushed to remote'.green
        result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Push local tags to the remote - this will only push tags"
      end

      def self.available_options
        [
        ]
      end

      def self.author
        ['vittoriom']
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
