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

        notify_room = (options[:notify_room] ? 'true' : 'false')

        channel = options[:channel]
        color = (options[:success] ? 'green' : 'red')
        
        the_message = options[:message]
        message = "<table><tr><td><img src='https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png' width='50' height='50'></td><td>#{the_message[0..9999]}</td></tr></table>"

        if api_version.to_i == 1
          ########## running on V1 ##########
          if user?(channel)
            raise 'HipChat private message not working with API V1 please use API V2 instead'.red
          else
            uri = URI.parse("https://#{api_host}/v1/rooms/message")
            response = Net::HTTP.post_form(uri, { 'from' => 'fastlane',
                                                  'auth_token' => api_token,
                                                  'color' => color,
                                                  'message_format' => 'html',
                                                  'room_id' => channel,
                                                  'message' => message,
                                                  'notify' => notify_room })

            check_response_code(response, channel)
          end
        else
          ########## running on V2 ##########
          if user?(channel)
            channel.slice!(0)
            params = { 'message' => message, 'message_format' => 'html' }
            json_headers = { 'Content-Type' => 'application/json',
                             'Accept' => 'application/json', 'Authorization' => "Bearer #{api_token}" }

            uri = URI.parse("https://#{api_host}/v2/user/#{channel}/message")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true

            response = http.post(uri.path, params.to_json, json_headers)
            check_response_code(response, channel)
          else
            uri = URI.parse("https://#{api_host}/v2/room/#{channel}/notification")
            response = Net::HTTP.post_form(uri, { 'from' => 'fastlane',
                                                  'auth_token' => api_token,
                                                  'color' => color,
                                                  'message_format' => 'html',
                                                  'message' => message,
                                                  'notify' => notify_room })

            check_response_code(response, channel)
          end
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
            raise "Channel `#{channel}` not found".red
          when 401
            raise "Access denied for channel `#{channel}`".red
          else
            raise "Unexpected #{response.code} for `#{channel}` with response: #{response.body}".red
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
                                       description: "Hipchat API Token",
                                       verify_block: Proc.new do |value|
                                        unless value.to_s.length > 0
                                          Helper.log.fatal "Please add 'ENV[\"HIPCHAT_API_TOKEN\"] = \"your token\"' to your Fastfile's `before_all` section.".red
                                          raise 'No HIPCHAT_API_TOKEN given.'.red
                                        end
                                       end),
          FastlaneCore::ConfigItem.new(key: :success,
                                       env_name: "FL_HIPCHAT_SUCCESS",
                                       description: "Was this build successful? (true/false)",
                                       optional: true,
                                       default_value: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "HIPCHAT_API_VERSION",
                                       description: "Version of the Hipchat API. Must be 1 or 2",
                                       verify_block: Proc.new do |value|
                                        if value.nil? || ![1, 2].include?(value.to_i)
                                          Helper.log.fatal "Please add 'ENV[\"HIPCHAT_API_VERSION\"] = \"1 or 2\"' to your Fastfile's `before_all` section.".red
                                          raise 'No HIPCHAT_API_VERSION given.'.red
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
                                       optional: true)
          ]
      end

      def self.author
        "jingx23"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
