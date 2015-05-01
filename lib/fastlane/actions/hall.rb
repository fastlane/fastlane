module Fastlane
  module Actions
    module SharedValues
    end

    class HallAction < Action
      def self.run(options)

        require 'net/http'
        require 'uri'

        group_api_token = options[:group_api_token]

        title = options[:title]
        message = options[:message]
        picture = options[:picture]

        uri = URI.parse("https://hall.com/api/1/services/generic/#{group_api_token}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, initheader = {"Content-Type" =>"application/json",
                                                          "Accept" => "application/json"})
        req.body = {"title" => title,
                    "message" => message}.to_json

        res = http.request(req)
        check_response_code(res)

        Helper.log.info "Posted message to Hall 🎯."
      end

      def self.check_response_code(response)
        case response.code.to_i
        when 200, 201, 204
          true
        when 404
          raise "Not found".red
        when 401
          raise "Access denied".red
        else
          raise "Unexpected #{response.code}".red
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Post a message to Hall (https://hall.com/)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :title,
                                       env_name: "FL_HALL_TITLE",
                                       description: "The title for the message. Plain text, HTML tags will be stripped",
                                       default_value: 'fastlane'),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_HALL_MESSAGE",
                                       description: "The message to post on the Hall group. May contain a restricted set of HTML tags (https://hall.com/docs/integrations/generic)",
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :picture,
                                       env_name: "FL_HALL_PICTURE",
                                       description: "URL to an image file, which will be displayed next to your notification message",
                                       default_value: 'https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png'),
          FastlaneCore::ConfigItem.new(key: :group_api_token,
                                       env_name: "HALL_GROUP_API_TOKEN",
                                       description: "Hall Group API Token",
                                       verify_block: Proc.new do |value|
                                         unless value.to_s.length > 0
                                           Helper.log.fatal "Please add 'ENV[\"HALL_GROUP_API_TOKEN\"] = \"your token\"' to your Fastfile's `before_all` section.".red
                                           raise 'No HALL_GROUP_API_TOKEN given.'.red
                                         end
          end)
        ]
      end

      def self.output
        [
        ]
      end

      def self.author
        'eytanbiala'
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
