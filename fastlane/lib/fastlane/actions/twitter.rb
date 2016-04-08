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
        "Post on twitter"
      end

      def self.details
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :consumer_key,
                                       env_name: "FL_TW_CONSUMER_KEY",
                                       description: "Consumer Key",
                                       is_string: true,
                                       optional: false
                                      ),
          FastlaneCore::ConfigItem.new(key: :consumer_secret,
                                       env_name: "FL_TW_CONSUMER_SECRET",
                                       description: "Consumer Secret",
                                       is_string: true,
                                       optional: false
                                      ),
          FastlaneCore::ConfigItem.new(key: :access_token,
                                       env_name: "FL_TW_ACCESS_TOKEN",
                                       description: "Access Token",
                                       is_string: true,
                                       optional: false
                                      ),
          FastlaneCore::ConfigItem.new(key: :access_token_secret,
                                       env_name: "FL_TW_ACCESS_TOKEN_SECRET",
                                       description: "Access Token Secret",
                                       is_string: true,
                                       optional: false
                                      ),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_TW_MESSAGE",
                                       description: "The tweet",
                                       is_string: true,
                                       optional: false
                                      )

        ]
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
