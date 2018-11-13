module Fastlane
  module Actions
    module SharedValues
      APPETIZE_PUBLIC_KEY = :APPETIZE_PUBLIC_KEY
      APPETIZE_APP_URL = :APPETIZE_APP_URL
      APPETIZE_MANAGE_URL = :APPETIZE_MANAGE_URL
    end

    class AppetizeAction < Action
      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end

      def self.run(options)
        require 'net/http'
        require 'net/http/post/multipart'
        require 'uri'
        require 'json'

        params = {
          platform: options[:platform]
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

        if params[:platform] == 'ios'
          UI.message("Uploading ipa to appetize... this might take a while")
        else
          UI.message("Uploading apk to appetize... this might take a while")
        end

        response = http.request(req)

        parse_response(response) # this will raise an exception if something goes wrong

        UI.message("App URL: #{Actions.lane_context[SharedValues::APPETIZE_APP_URL]}")
        UI.message("Manage URL: #{Actions.lane_context[SharedValues::APPETIZE_MANAGE_URL]}")
        UI.message("Public Key: #{Actions.lane_context[SharedValues::APPETIZE_PUBLIC_KEY]}")
        UI.success("Build successfully uploaded to Appetize.io")
      end

      def self.appetize_url(options)
        "https://api.appetize.io/v1/apps/#{options[:public_key]}"
      end
      private_class_method :appetize_url

      def self.create_request(uri, params)
        if params[:url]
          req = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
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
        public_key = body['publicKey']

        Actions.lane_context[SharedValues::APPETIZE_PUBLIC_KEY] = public_key
        Actions.lane_context[SharedValues::APPETIZE_APP_URL] = app_url
        Actions.lane_context[SharedValues::APPETIZE_MANAGE_URL] = manage_url
        return true
      rescue => ex
        UI.error(ex)
        UI.user_error!("Error uploading to Appetize.io: #{response.body}")
      end
      private_class_method :parse_response

      def self.description
        "Upload your app to [Appetize.io](https://appetize.io/) to stream it in browser"
      end

      def self.details
        [
          "If you provide a `public_key`, this will overwrite an existing application. If you want to have this build as a new app version, you shouldn't provide this value.",
          "",
          "To integrate appetize into your GitHub workflow check out the [device_grid guide](https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/device_grid/README.md)."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "APPETIZE_API_TOKEN",
                                       sensitive: true,
                                       description: "Appetize.io API Token",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No API Token for Appetize.io given, pass using `api_token: 'token'`") unless value.to_s.length > 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "APPETIZE_URL",
                                       description: "URL from which the ipa file can be fetched. Alternative to :path",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "APPETIZE_PLATFORM",
                                       description: "Platform. Either `ios` or `android`",
                                       is_string: true,
                                       default_value: 'ios'),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "APPETIZE_FILE_PATH",
                                       description: "Path to zipped build on the local filesystem. Either this or `url` must be specified",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :public_key,
                                       env_name: "APPETIZE_PUBLICKEY",
                                       description: "If not provided, a new app will be created. If provided, the existing build will be overwritten",
                                       is_string: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         if value.start_with?("private_")
                                           UI.user_error!("You provided a private key to appetize, please provide the public key")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :note,
                                       env_name: "APPETIZE_NOTE",
                                       description: "Notes you wish to add to the uploaded app",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['APPETIZE_PUBLIC_KEY', 'a public identifier for your app. Use this to update your app after it has been initially created'],
          ['APPETIZE_APP_URL', 'a page to test and share your app.'],
          ['APPETIZE_MANAGE_URL', 'a page to manage your app.']
        ]
      end

      def self.authors
        ["klundberg", "giginet"]
      end

      def self.category
        :beta
      end

      def self.example_code
        [
          'appetize(
            path: "./MyApp.zip",
            api_token: "yourapitoken", # get it from https://appetize.io/docs#request-api-token
            public_key: "your_public_key" # get it from https://appetize.io/dashboard
          )'
        ]
      end
    end
  end
end
