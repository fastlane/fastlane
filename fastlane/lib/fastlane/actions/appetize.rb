module Fastlane
  module Actions
    module SharedValues
      APPETIZE_PRIVATE_KEY = :APPETIZE_PRIVATE_KEY
      APPETIZE_PUBLIC_KEY = :APPETIZE_PUBLIC_KEY
      APPETIZE_APP_URL = :APPETIZE_APP_URL
      APPETIZE_MANAGE_URL = :APPETIZE_MANAGE_URL
    end

    class AppetizeAction < Action
      APPETIZE_URL_BASE = 'https://api.appetize.io/v1/app/update'

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.run(options)
        require 'net/http'
        require 'uri'
        require 'json'

        uri = URI.parse(APPETIZE_URL_BASE)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        req = Net::HTTP::Post.new(uri.request_uri, initheader: {'Content-Type' => 'application/json'})
        params = {
            token: options[:api_token],
            url: options[:url],
            platform: 'ios'
        }

        params[:privateKey] = options[:private_key] unless options[:private_key].nil?
        req.body = JSON.generate(params)
        response = https.request(req)

        raise 'Error when trying to upload ipa to Appetize.io'.red unless parse_response(response)
        Helper.log.info "App URL: #{Actions.lane_context[SharedValues::APPETIZE_APP_URL]}"
        Helper.log.info "Manage URL: #{Actions.lane_context[SharedValues::APPETIZE_MANAGE_URL]}"
        Helper.log.info "App Private Key: #{Actions.lane_context[SharedValues::APPETIZE_PRIVATE_KEY]}"
        Helper.log.info "Build successfully uploaded to Appetize.io".green
      end

      def self.parse_response(response)
        body = JSON.parse(response.body)
        app_url = body['appURL']
        manage_url = body['manageURL']
        private_key = body['privateKey']
        public_key = body['publicKey']

        Actions.lane_context[SharedValues::APPETIZE_PRIVATE_KEY] = private_key
        Actions.lane_context[SharedValues::APPETIZE_PUBLIC_KEY] = public_key
        Actions.lane_context[SharedValues::APPETIZE_APP_URL] = app_url
        Actions.lane_context[SharedValues::APPETIZE_MANAGE_URL] = manage_url
        return true
      rescue
        Helper.log.fatal "Error uploading to Appetize.io: #{response.body}".red
        help_message(response)
        return false
      end
      private_class_method :parse_response

      def self.help_message(response)
        message = case response.body
                  when 'Invalid token'
                    'Invalid API Token specified.'
                  when 'Error downloading zip file'
                    'URL should be wrong'
                  when 'No app with specified privateKey found'
                    'Invalid privateKey specified'
                  end
        Helper.log.error message.red if message
      end
      private_class_method :help_message

      def self.description
        "Create or Update apps on Appetize.io"
      end

      def self.available_options
        [FastlaneCore::ConfigItem.new(key: :api_token,
                                      env_name: "APPETIZE_API_TOKEN",
                                      description: "Appetize.io API Token",
                                      is_string: true,
                                      verify_block: proc do |value|
                                        raise "No API Token for Appetize.io given, pass using `api_token: 'token'`".red unless value.to_s.length > 0
                                      end),
         FastlaneCore::ConfigItem.new(key: :url,
                                      env_name: "APPETIZE_URL",
                                      description: "Target url of the zipped build",
                                      is_string: true,
                                      verify_block: proc do |value|
                                        raise "No URL of your zipped build".red unless value.to_s.length > 0
                                      end),
         FastlaneCore::ConfigItem.new(key: :private_key,
                                      env_name: "APPETIZE_PRIVATEKEY",
                                      description: "privateKey which specify each applications",
                                      optional: true)
        ]
      end

      def self.output
        [
          ['APPETIZE_PRIVATE_KEY', 'a string that is used to prove "ownership" of your app - save this so that you may subsequently update the app'],
          ['APPETIZE_PUBLIC_KEY', 'a public identiifer for your app'],
          ['APPETIZE_APP_URL', 'a page to test and share your app'],
          ['APPETIZE_MANAGE_URL', 'a page to manage your app']
        ]
      end

      def self.author
        "giginet"
      end
    end
  end
end
