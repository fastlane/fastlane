module Fastlane
  module Actions
    class FlockAction < Action
      BASE_URL = 'https://api.flock.co/hooks/sendMessage'.freeze

      def self.run(options)
        require 'net/http'
        require 'uri'
        require 'json'

        notify_incoming_message_webhook(options[:base_url], options[:message], options[:token])
      end

      def self.notify_incoming_message_webhook(base_url, message, token)
        uri = URI.join(base_url + '/', token)
        response = Net::HTTP.start(
          uri.host, uri.port, use_ssl: uri.scheme == 'https'
        ) do |http|
          request = Net::HTTP::Post.new(uri.path)
          request.content_type = 'application/json'
          request.body = JSON.generate("text" => message)
          http.request(request)
        end
        if response.kind_of?(Net::HTTPSuccess)
          UI.success('Message sent to Flock.')
        else
          UI.error("HTTP request to '#{uri}' with message '#{message}' failed with a #{response.code} response.")
          UI.user_error!('Error sending message to Flock. Please verify the Flock webhook token.')
        end
      end

      def self.description
        "Send a message to a [Flock](https://flock.com/) group"
      end

      def self.details
        "To obtain the token, create a new [incoming message webhook](https://dev.flock.co/wiki/display/FlockAPI/Incoming+Webhooks) in your Flock admin panel."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: 'FL_FLOCK_MESSAGE',
                                       description: 'Message text'),
          FastlaneCore::ConfigItem.new(key: :token,
                                       env_name: 'FL_FLOCK_TOKEN',
                                       sensitive: true,
                                       description: 'Token for the Flock incoming webhook'),
          FastlaneCore::ConfigItem.new(key: :base_url,
                                       env_name: 'FL_FLOCK_BASE_URL',
                                       description: 'Base URL of the Flock incoming message webhook',
                                       optional: true,
                                       default_value: BASE_URL,
                                       verify_block: proc do |value|
                                         UI.user_error!('Invalid https URL') unless value.start_with?('https://')
                                       end)
        ]
      end

      def self.author
        "Manav"
      end

      def self.example_code
        [
          'flock(
            message: "Hello",
            token: "xxx"
          )'
        ]
      end

      def self.category
        :notifications
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
