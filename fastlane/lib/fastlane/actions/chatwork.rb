module Fastlane
  module Actions
    module SharedValues
    end

    class ChatworkAction < Action
      def self.run(options)
        require 'net/http'
        require 'uri'

        emoticon = (options[:success] ? '(dance)' : ';(')

        uri = URI.parse("https://api.chatwork.com/v1/rooms/#{options[:roomid]}/messages")
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
          Helper.log.info 'Successfully sent notification to ChatWork right now 📢'.green
        else
          require 'json'
          json = JSON.parse(response.body)
          raise "HTTP Error: #{response.code} #{json['errors']}".red
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
                                       verify_block: proc do |value|
                                         unless value.to_s.length > 0
                                           Helper.log.fatal "Please add 'ENV[\"CHATWORK_API_TOKEN\"] = \"your token\"' to your Fastfile's `before_all` section.".red
                                           raise 'No CHATWORK_API_TOKEN given.'.red
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
        "ChatWork Inc."
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
