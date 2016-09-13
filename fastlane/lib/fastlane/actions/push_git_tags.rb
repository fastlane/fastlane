module Fastlane
  module Actions
    class PushGitTagsAction < Action
      def self.run(params)
        command = [
          'git',
          'push',
          params[:remote],
          '--tags'
        ]

        # optionally add the force component
        command << '--force' if params[:force]

        result = Actions.sh(command.join(' '))
        UI.success('Tags pushed to remote')
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
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_PUSH_GIT_FORCE",
                                       description: "Force push to remote. Defaults to false",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :remote,
                                       env_name: "FL_GIT_PUSH_REMOTE",
                                       description: "The remote to push to. Defaults to `origin`",
                                       default_value: 'origin')
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
