module Fastlane
  module Actions
    class TypetalkAction < Action
      def self.run(params)
        options = {
            message: nil,
            note_path: nil,
            success: true,
            topic_id: nil,
            typetalk_token: nil
        }.merge(params || {})

        [:message, :topic_id, :typetalk_token].each do |key|
          raise "No #{key} given.".red unless options[key]
        end

        emoticon = (options[:success] ? ':smile:' : ':rage:')
        message = "#{emoticon} #{options[:message]}"

        note_path = File.expand_path(options[:note_path]) if options[:note_path]
        if note_path and File.exist?(note_path)
          contents = File.read(note_path)
          message += "\n\n```\n#{contents}\n```"
        end

        topic_id = options[:topic_id]
        typetalk_token = options[:typetalk_token]

        self.post_to_typetalk(message, topic_id, typetalk_token)

        Helper.log.info 'Successfully sent Typetalk notification'.green
      end

      def self.post_to_typetalk(message, topic_id, typetalk_token)
        require 'net/http'
        require 'uri'

        uri = URI.parse("https://typetalk.in/api/v1/topics/#{topic_id}")
        response = Net::HTTP.post_form(uri, {'message' => message,
                                             'typetalkToken' => typetalk_token})

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

      def self.description
        "Post a message to Typetalk"
      end

      def self.available_options
        [
          ['message', 'The message to post'],
          ['note_path', 'Path to an additional note'],
          ['topic_id', 'Typetalk topic id'],
          ['success', 'Successful build?'],
          ['typetalk_token', 'typetalk token']
        ]
      end

      def self.author
        "Nulab Inc."
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
