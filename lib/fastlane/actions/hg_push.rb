module Fastlane
  module Actions
    # Pushes commits to the remote hg repo
    class HgPushAction < Action
      def self.run(params)
        command = ['hg', 'push']

        command << '--force' if params[:force]
        command << params[:destination] unless params[:destination].empty?

        return command.join(' ') if Helper.is_test?

        Actions.sh(command.join(' '))
        Helper.log.info 'Successfully pushed changes to remote 🚀.'.green
      end

      def self.description
        "This will push changes to the remote hg repository"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_HG_PUSH_FORCE",
                                       description: "Force push to remote. Defaults to false",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :destination,
                                       env_name: "FL_HG_PUSH_DESTINATION",
                                       description: "The destination to push to",
                                       default_value: '',
                                       optional: true)
        ]
      end

      def self.author
        # credits to lmirosevic for original git version
        "sjrmanning"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
