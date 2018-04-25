module Fastlane
  module Actions
    module SharedValues
    end

    class ChatworkAction < Action
      def self.run(options)
        require 'net/http'
        require 'uri'

        emoticon = (options[:success] ? '(dance)' : ';(')

        uri = URI.parse("https://api.chatwork.com/v2/rooms/#{options[:roomid]}/messages")
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        req = Net::HTTP::Post.new(uri.request_uri)
        req['X-ChatWorkToken'] = options[:api_token]
        req.set_form_data({
          'body' => "[info][title]Notification from fastlane[/title]#{emoticon} #{options[:message]}[/info]"
        })

        response = https.request(req)
        case response.code.to_i
        when 200..299
          UI.success('Successfully sent notification to ChatWork right now 📢')
        else
          require 'json'
          json = JSON.parse(response.body)
          UI.user_error!("HTTP Error: #{response.code} #{json['errors']}")
        end
      end

      def self.description
        "Send a success/error message to ChatWork"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "CHATWORK_API_TOKEN",
                                       description: "ChatWork API Token",
                                       sensitive: true,
                                       verify_block: proc do |value|
                                         unless value.to_s.length > 0
                                           UI.error("Please add 'ENV[\"CHATWORK_API_TOKEN\"] = \"your token\"' to your Fastfile's `before_all` section.")
                                           UI.user_error!("No CHATWORK_API_TOKEN given.")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_CHATWORK_MESSAGE",
                                       description: "The message to post on ChatWork"),
          FastlaneCore::ConfigItem.new(key: :roomid,
                                       env_name: "FL_CHATWORK_ROOMID",
                                       description: "The room ID",
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :success,
                                       env_name: "FL_CHATWORK_SUCCESS",
                                       description: "Was this build successful? (true/false)",
                                       optional: true,
                                       default_value: true,
                                       is_string: false)
        ]
      end

      def self.author
        "astronaughts"
      end

      def self.is_supported?(platform)
        true
      end

      def self.details
        "Information on how to obtain an API token: [http://developer.chatwork.com/ja/authenticate.html](http://developer.chatwork.com/ja/authenticate.html)"
      end

      def self.example_code
        [
          'chatwork(
            message: "App successfully released!",
            roomid: 12345,
            success: true,
            api_token: "Your Token"
          )'
        ]
      end

      def self.category
        :notifications
      end
    end
  end
end
