module Fastlane
  module Actions
    module SharedValues
    end

    class HipchatAction
      def self.run(params)
        options = { message: '',
                    success: true,
                    channel: nil
                  }.merge(params.first || {})

        require 'net/http'
        require 'uri'

        api_token = ENV['HIPCHAT_API_TOKEN']
        api_version = ENV['HIPCHAT_API_VERSION']

        unless api_token
          Helper.log.fatal "Please add 'ENV[\"HIPCHAT_API_TOKEN\"] = \"your token\"' to your Fastfile's `before_all` section.".red
          raise 'No HIPCHAT_API_TOKEN given.'.red
        end
        if api_version.nil? || ![1, 2].include?(api_version[0].to_i)
          Helper.log.fatal "Please add 'ENV[\"HIPCHAT_API_VERSION\"] = \"1 or 2\"' to your Fastfile's `before_all` section.".red
          raise 'No HIPCHAT_API_VERSION given.'.red
        end

        channel = options[:channel]
        color = (options[:success] ? 'green' : 'red')
        message = "<table><tr><td><img src=\"https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png\" style=\"width:50px;height:auto\"></td><td>" + options[:message] + '</td></tr></table>'

        if api_version.to_i == 1
          ########## running on V1 ##########
          if user?(channel)
            raise 'HipChat private message not working with API V1 please use API V2 instead'.red
          else
            uri = URI.parse('https://api.hipchat.com/v1/rooms/message')
            response = Net::HTTP.post_form(uri, { 'from' => 'fastlane',
                                                  'auth_token' => api_token,
                                                  'color' => color,
                                                  'message_format' => 'html',
                                                  'room_id' => channel,
                                                  'message' => message })

            checkResponseCodeForRoom(response, channel)
          end
        else
          ########## running on V2 ##########
          if user?(channel)
            channel.slice!(0)
            params = { 'message' => message, 'message_format' => 'html' }
            json_headers = { 'Content-Type' => 'application/json',
                             'Accept' => 'application/json', 'Authorization' => "Bearer #{api_token}" }

            uri = URI.parse("https://api.hipchat.com/v2/user/#{channel}/message")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true

            response = http.post(uri.path, params.to_json, json_headers)
            check_response_code(response, channel)
          else
            uri = URI.parse("https://api.hipchat.com/v2/room/#{channel}/notification")
            response = Net::HTTP.post_form(uri, { 'from' => 'fastlane',
                                                  'auth_token' => api_token,
                                                  'color' => color,
                                                  'message_format' => 'html',
                                                  'message' => message })

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
            raise "Unknown #{channel}".red
          when 401
            raise "Access denied #{channel}".red
          else
            raise "Unexpected #{response.code} for `#{channel}'".red
        end
      end
    end
  end
end
