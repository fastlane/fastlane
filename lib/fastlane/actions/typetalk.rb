module Fastlane
  module Actions
    class TypetalkAction
      def self.run(params)
        options = {
            message: nil,
            success: true,
            topicId: nil,
            typetalkToken: nil,
        }.merge(params.first || {})

        [:message, :topicId, :typetalkToken].each { |key|
          raise "No #{key} given.".red unless options[key]
        }

        emoticon = (options[:success] ? ':smile:' : ':rage:')
        message = "#{emoticon} #{options[:message].to_s}"
        topicId = options[:topicId]
        typetalkToken = options[:typetalkToken]

        self.post_to_typetalk(message, topicId, typetalkToken)

        Helper.log.info 'Successfully sent Typetalk notification'.green
      end

      def self.post_to_typetalk(message, topicId, typetalkToken)
        require 'net/http'
        require 'uri'

        uri = URI.parse("https://typetalk.in/api/v1/topics/#{topicId}")
        response = Net::HTTP.post_form(uri, {'message' => message,
                                             'typetalkToken' => typetalkToken})

        self.check_response(response)
      end

      def self.check_response(response)
        case response.code.to_i
          when 200, 204
            true
          else
            raise "Could not sent Typetalk notification".red
        end
      end
    end
  end
end
