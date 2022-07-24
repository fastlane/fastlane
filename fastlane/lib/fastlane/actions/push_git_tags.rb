module Fastlane
  module Actions
    class PushGitTagsAction < Action
      def self.run(params)
        command = [
          'git',
          'push',
          params[:remote]
        ]

        if params[:tag]
          command << "refs/tags/#{params[:tag].shellescape}"
        else
          command << '--tags'
        end

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
                                       description: "Force push to remote",
                                       type: Boolean,
                                       default_value: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :remote,
                                       env_name: "FL_GIT_PUSH_REMOTE",
                                       description: "The remote to push tags to",
                                       default_value: "origin",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :tag,
                                       env_name: "FL_GIT_PUSH_TAG",
                                       description: "The tag to push to remote",
                                       optional: true)
        ]
      end

      def self.author
        ['vittoriom']
      end

      def self.details
        "If you only want to push the tags and nothing else, you can use the `push_git_tags` action"
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'push_git_tags'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
