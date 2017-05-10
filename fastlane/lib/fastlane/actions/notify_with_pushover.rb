module Fastlane
  module Actions
    class NotifyWithPushoverAction < Action
      def self.run(params)
        api_token = params[:api_token]
        user_key = params[:user_key]
        title = params[:title]
        message = params[:message]

        UI.message "Parameter Title: #{title}"
        UI.message "Parameter Message: #{message}"

        sh "curl -s -F \"token=#{api_token}\" \
          -F \"user=#{user_key}\" \
          -F \"title=#{title}\" \
          -F \"message=#{message}\" https://api.pushover.net/1/messages.json"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Sends push notifications using Pushover"
      end

      def self.details
        "You can use this action to create and send custom push notifications via Pushover (https://pushover.net), for example to notify on Fastlane success or failure."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_NOTIFY_WITH_PUSHOVER_API_TOKEN",
                                       description: "API Token for Pushover",
                                       verify_block: proc do |value|
                                         UI.user_error!("No API token for NotifyWithPushoverAction given, pass using `api_token: 'token'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :user_key,
                                       env_name: "FL_NOTIFY_WITH_PUSHOVER_USER_KEY",
                                       description: "Pushover User Key to identify notification recipient",
                                       verify_block: proc do |value|
                                         UI.user_error!("No User Key for NotifyWithPushoverAction given, pass using `user_key: 'userKey'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :title,
                                       env_name: "FL_NOTIFY_WITH_PUSHOVER_TITLE",
                                       description: "Title for notification",
                                       default_value: "Fastlane Notification"),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_NOTIFY_WITH_PUSHOVER_MESSAGE",
                                       description: "Message for notification",
                                       verify_block: proc do |value|
                                         UI.user_error!("No message for NotifyWithPushoverAction given, pass using `message: 'My super message.'`") unless value and !value.empty?
                                       end)
        ]
      end

      def self.authors
        ["teddynewell"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
