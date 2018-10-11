module Fastlane
  module Actions
    class TwitterAction < Action
      def self.run(params)
        Actions.verify_gem!("twitter")
        require 'twitter'
        client = Twitter::REST::Client.new do |config|
          config.consumer_key        = params[:consumer_key]
          config.consumer_secret     = params[:consumer_secret]
          config.access_token        = params[:access_token]
          config.access_token_secret = params[:access_token_secret]
        end
        client.update(params[:message])
        UI.message(['[TWITTER]', "Successfully tweeted ", params[:message]].join(': '))
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Post a tweet on [Twitter.com](https://twitter.com)"
      end

      def self.details
        "Post a tweet on Twitter. Requires you to setup an app on [twitter.com](https://twitter.com) and obtain `consumer` and `access_token`."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :consumer_key,
                                       env_name: "FL_TW_CONSUMER_KEY",
                                       description: "Consumer Key",
                                       sensitive: true,
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :consumer_secret,
                                       env_name: "FL_TW_CONSUMER_SECRET",
                                       sensitive: true,
                                       description: "Consumer Secret",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :access_token,
                                       env_name: "FL_TW_ACCESS_TOKEN",
                                       sensitive: true,
                                       description: "Access Token",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :access_token_secret,
                                       env_name: "FL_TW_ACCESS_TOKEN_SECRET",
                                       sensitive: true,
                                       description: "Access Token Secret",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_TW_MESSAGE",
                                       description: "The tweet",
                                       is_string: true,
                                       optional: false)

        ]
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'twitter(
            access_token: "XXXX",
            access_token_secret: "xxx",
            consumer_key: "xxx",
            consumer_secret: "xxx",
            message: "You rock!"
          )'
        ]
      end

      def self.category
        :notifications
      end
    end
  end
end
