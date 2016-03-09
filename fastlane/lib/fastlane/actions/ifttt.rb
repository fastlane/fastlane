module Fastlane
  module Actions
    class IftttAction < Action
      def self.run(options)
        require "net/http"
        require "uri"

        uri = URI.parse("https://maker.ifttt.com/trigger/#{options[:event_name]}/with/key/#{options[:api_key]}")
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        req = Net::HTTP::Post.new(uri.request_uri)

        req.set_form_data({
          "value1" => options[:value1],
          "value2" => options[:value2],
          "value3" => options[:value3]
        })

        response = https.request(req)

        UI.user_error! "Failed to make a request to IFTTT. #{response.message}." unless response.code == "200"
        UI.success "Successfully made a request to IFTTT."
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Connect to the IFTTT Maker Channel. https://ifttt.com/maker"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                      env_name: "IFTTT_API_KEY",
                                      description: "API key",
                                      verify_block: proc do |value|
                                        raise UI.error "No API key given, pass using `api_key: 'key'`" if value.to_s.empty?
                                      end),
          FastlaneCore::ConfigItem.new(key: :event_name,
                                      env_name: "IFTTT_EVENT_NAME",
                                      description: "The name of the event that will be triggered",
                                      verify_block: proc do |value|
                                        raise UI.error "No event name given, pass using `event_name: 'name'`" if value.to_s.empty?
                                      end),
          FastlaneCore::ConfigItem.new(key: :value1,
                                       env_name: "IFTTT_VALUE1",
                                       description: "Extra data sent with the event",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :value2,
                                      env_name: "IFTTT_VALUE2",
                                      description: "Extra data sent with the event",
                                      optional: true,
                                      is_string: true),
          FastlaneCore::ConfigItem.new(key: :value3,
                                       env_name: "IFTTT_VALUE3",
                                       description: "Extra data sent with the event",
                                       optional: true,
                                       is_string: true)]
      end

      def self.is_supported?(platform)
        true
      end

      def self.authors
        ["vpolouchkine"]
      end
    end
  end
end
