module Fastlane
  module Actions
    module SharedValues
    end

    class HipchatAction < Action
      def self.run(options)
        require 'net/http'
        require 'uri'

        api_token = options[:api_token]
        api_version = options[:version]
        api_host = options[:api_host]

        message_format = options[:message_format]

        channel = options[:channel]
        if ['yellow', 'red', 'green', 'purple', 'gray', 'random'].include?(options[:custom_color]) == true
          color = options[:custom_color]
        else
          color = (options[:success] ? 'green' : 'red')
        end

        from = options[:from]

        message = options[:message]
        if (message_format == "html") && (options[:include_html_header] == true)
          message = "<table><tr><td><img src='https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png' width='50' height='50'></td><td>#{message[0..9999]}</td></tr></table>"
        end

        if api_version.to_i == 1
          ########## running on V1 ##########
          if user?(channel)
            UI.user_error!("HipChat private message not working with API V1 please use API V2 instead")
          else
            uri = URI.parse("https://#{api_host}/v1/rooms/message")
            response = Net::HTTP.post_form(uri, { 'from' => from,
                                                  'auth_token' => api_token,
                                                  'color' => color,
                                                  'message_format' => message_format,
                                                  'room_id' => channel,
                                                  'message' => message,
                                                  'notify' => options[:notify_room] ? '1' : '0' })

            check_response_code(response, channel)
          end
        else
          ########## running on V2 ##########
          # Escape channel's name to guarantee it is a valid URL resource.
          # First of all we verify that the value is not already escaped,
          # escaping an escaped value will produce a wrong channel name.
          escaped_channel = URI.unescape(channel) == channel ? URI.escape(channel) : channel
          if user?(channel)
            params = { 'message' => message, 'message_format' => message_format }
            json_headers = { 'Content-Type' => 'application/json',
                             'Accept' => 'application/json', 'Authorization' => "Bearer #{api_token}" }

            uri = URI.parse("https://#{api_host}/v2/user/#{escaped_channel}/message")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true

            response = http.post(uri.path, params.to_json, json_headers)
          else
            uri = URI.parse("https://#{api_host}/v2/room/#{escaped_channel}/notification")
            response = Net::HTTP.post_form(uri, { 'from' => from,
                                                  'auth_token' => api_token,
                                                  'color' => color,
                                                  'message_format' => message_format,
                                                  'message' => message,
                                                  'notify' => options[:notify_room] ? 'true' : 'false' })
          end
          check_response_code(response, channel)
        end
      end

      def self.user?(channel)
        channel.to_s.start_with?('@')
      end

      def self.check_response_code(response, channel)
        case response.code.to_i
        when 200, 204
          true
        when 404
          UI.user_error!("Channel `#{channel}` not found")
        when 401
          UI.user_error!("Access denied for channel `#{channel}`")
        else
          UI.user_error!("Unexpected #{response.code} for `#{channel}` with response: #{response.body}")
        end
      end

      def self.description
        "Send a error/success message to HipChat"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_HIPCHAT_MESSAGE",
                                       description: "The message to post on HipChat",
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :channel,
                                       env_name: "FL_HIPCHAT_CHANNEL",
                                       description: "The room or @username"),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "HIPCHAT_API_TOKEN",
                                       sensitive: true,
                                       description: "Hipchat API Token",
                                       verify_block: proc do |value|
                                         unless value.to_s.length > 0
                                           UI.error("Please add 'ENV[\"HIPCHAT_API_TOKEN\"] = \"your token\"' to your Fastfile's `before_all` section.")
                                           UI.user_error!("No HIPCHAT_API_TOKEN given.")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :custom_color,
                                       env_name: "FL_HIPCHAT_CUSTOM_COLOR",
                                       description: "Specify a custom color, this overrides the success boolean. Can be one of 'yellow', 'red', 'green', 'purple', 'gray', or 'random'",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :success,
                                       env_name: "FL_HIPCHAT_SUCCESS",
                                       description: "Was this build successful? (true/false)",
                                       optional: true,
                                       default_value: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "HIPCHAT_API_VERSION",
                                       description: "Version of the Hipchat API. Must be 1 or 2",
                                       verify_block: proc do |value|
                                         if value.nil? || ![1, 2].include?(value.to_i)
                                           UI.error("Please add 'ENV[\"HIPCHAT_API_VERSION\"] = \"1 or 2\"' to your Fastfile's `before_all` section.")
                                           UI.user_error!("No HIPCHAT_API_VERSION given.")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :notify_room,
                                       env_name: "HIPCHAT_NOTIFY_ROOM",
                                       description: "Should the people in the room be notified? (true/false)",
                                       default_value: false,
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :api_host,
                                       env_name: "HIPCHAT_API_HOST",
                                       description: "The host of the HipChat-Server API",
                                       default_value: "api.hipchat.com",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :message_format,
                                       env_name: "FL_HIPCHAT_MESSAGE_FORMAT",
                                       description: "Format of the message to post. Must be either 'html' or 'text'",
                                       default_value: "html",
                                       optional: true,
                                       verify_block: proc do |value|
                                         unless ["html", "text"].include?(value.to_s)
                                           UI.error("Please specify the message format as either 'html' or 'text'.")
                                           UI.user_error!("Unrecognized message_format.")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :include_html_header,
                                       env_name: "FL_HIPCHAT_INCLUDE_HTML_HEADER",
                                       description: "Should html formatted messages include a preformatted header? (true/false)",
                                       default_value: true,
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :from,
                                       env_name: "FL_HIPCHAT_FROM",
                                       description: "Name the message will appear to be sent from",
                                       default_value: "fastlane",
                                       optional: true)
        ]
      end

      def self.author
        "jingx23"
      end

      def self.is_supported?(platform)
        true
      end

      def self.details
        "Send a message to **room** (by default) or a direct message to **@username** with success (green) or failure (red) status."
      end

      def self.example_code
        [
          'hipchat(
            message: "App successfully released!",
            message_format: "html", # or "text", defaults to "html"
            channel: "Room or @username",
            success: true
          )'
        ]
      end

      def self.category
        :notifications
      end
    end
  end
end
