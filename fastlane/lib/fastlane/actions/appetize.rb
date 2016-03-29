module Fastlane
  module Actions
    module SharedValues
      APPETIZE_PRIVATE_KEY = :APPETIZE_PRIVATE_KEY
      APPETIZE_PUBLIC_KEY = :APPETIZE_PUBLIC_KEY
      APPETIZE_APP_URL = :APPETIZE_APP_URL
      APPETIZE_MANAGE_URL = :APPETIZE_MANAGE_URL
    end

    class AppetizeAction < Action
      def self.is_supported?(platform)
        platform == :ios
      end

      def self.run(options)
        require 'net/http'
        require 'net/http/post/multipart'
        require 'uri'
        require 'json'

        params = {
            platform: 'ios'
        }

        if options[:path]
          params[:file] = UploadIO.new(options[:path], 'application/zip')
        else
          UI.user_error!('url parameter is required if no file path is specified') if options[:url].nil?
          params[:url] = options[:url]
        end

        params[:note] = options[:note] if options[:note].to_s.length > 0

        uri = URI.parse(appetize_url(options))
        req = create_request(uri, params)
        req.basic_auth(options[:api_token], nil)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        response = http.request(req)

        UI.user_error!("Error uploading app to Appetize.io") unless parse_response(response)
        UI.message("App URL: #{Actions.lane_context[SharedValues::APPETIZE_APP_URL]}")
        UI.message("Manage URL: #{Actions.lane_context[SharedValues::APPETIZE_MANAGE_URL]}")
        UI.message("App Private Key: #{Actions.lane_context[SharedValues::APPETIZE_PRIVATE_KEY]}")
        UI.success("Build successfully uploaded to Appetize.io")
      end

      def self.appetize_url(options)
        "https://api.appetize.io/v1/apps/#{options[:public_key]}"
      end
      private_class_method :appetize_url

      def self.create_request(uri, params)
        if params[:url]
          req = Net::HTTP::Post.new(uri.request_uri, initheader: {'Content-Type' => 'application/json'})
          req.body = JSON.generate(params)
        else
          req = Net::HTTP::Post::Multipart.new(uri.path, params)
        end

        req
      end
      private_class_method :create_request

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
        UI.error("Error uploading to Appetize.io: #{response.body}")
        return false
      end
      private_class_method :parse_response

      def self.description
        "Create or Update apps on Appetize.io"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "APPETIZE_API_TOKEN",
                                       description: "Appetize.io API Token",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No API Token for Appetize.io given, pass using `api_token: 'token'`") unless value.to_s.length > 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "APPETIZE_URL",
                                       description: "Target url of the zipped build. Either this or `path` must be specified",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "APPETIZE_FILE_PATH",
                                       description: "Path to zipped build on the local filesystem. Either this or `url` must be specified",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :public_key,
                                       env_name: "APPETIZE_PUBLICKEY",
                                       description: "Public key of the app you wish to update. If not provided, then a new app entry will be created on Appetize.io",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :note,
                                       env_name: "APPETIZE_NOTE",
                                       description: "Notes you wish to add to the uploaded app",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['APPETIZE_PRIVATE_KEY', 'a string that is used to prove "ownership" of your app.'],
          ['APPETIZE_PUBLIC_KEY', 'a public identiifer for your app. Use this to update your app after it has been initially created'],
          ['APPETIZE_APP_URL', 'a page to test and share your app.'],
          ['APPETIZE_MANAGE_URL', 'a page to manage your app.']
        ]
      end

      def self.authors
        ["klundberg", "giginet"]
      end
    end
  end
end
