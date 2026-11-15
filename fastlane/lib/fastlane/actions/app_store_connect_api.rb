module Fastlane
  module Actions
    class AppStoreConnectApiAction < Action
      def self.run(params)
        require 'spaceship'

        # Reuse the key set by app_store_connect_api_key earlier in the lane.
        params[:api_key] ||= Actions.lane_context[SharedValues::APP_STORE_CONNECT_API_KEY]
        token = Spaceship::ConnectAPI::Token.from(hash: params[:api_key], filepath: params[:api_key_path])

        return Spaceship::ApiRunner.new(
          method: params[:http_method],
          path: params[:path],
          body: params[:body],
          paginate: params[:paginate],
          token: token,
          username: params[:username],
          yes: true
        ).request
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Send one App Store Connect API request and return Apple's JSON response"
      end

      def self.details
        "Calls any App Store Connect API endpoint, including those _spaceship_ has no model for. Uses the API key from `api_key`, `api_key_path` or an earlier `app_store_connect_api_key`, else the Apple ID session. The same request is available from the command line as `fastlane spaceship api`."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :http_method,
                                       description: "The HTTP method: GET, POST, PATCH or DELETE",
                                       default_value: "GET",
                                       verify_block: proc do |value|
                                         UI.user_error!("Unsupported http_method '#{value}', use one of #{Spaceship::ApiRunner::METHODS.join(', ')}") unless Spaceship::ApiRunner::METHODS.include?(value.to_s.upcase)
                                       end),
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The request path with its query, e.g. /v1/apps?limit=200",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :body,
                                       description: "The JSON request body, for POST and PATCH",
                                       type: Hash,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :paginate,
                                       description: "Follow links.next and return all pages as one response (GET only)",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :api_key_path,
                                       env_name: "APP_STORE_CONNECT_API_KEY_PATH",
                                       description: "Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)",
                                       optional: true,
                                       conflicting_options: [:api_key],
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find API key JSON file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "APP_STORE_CONNECT_API_KEY",
                                       description: "Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-hash-option)",
                                       type: Hash,
                                       optional: true,
                                       sensitive: true,
                                       conflicting_options: [:api_key_path]),
          FastlaneCore::ConfigItem.new(key: :username,
                                       description: "Your Apple ID, when no API key is given. Defaults to the Appfile's apple_id",
                                       optional: true)
        ]
      end

      def self.return_value
        "The parsed JSON response, or nil when Apple sends no body"
      end

      def self.return_type
        :hash
      end

      def self.authors
        ["lacostej"]
      end

      def self.is_supported?(platform)
        [:ios, :mac, :tvos].include?(platform)
      end

      def self.example_code
        [
          'app_store_connect_api_key(key_id: "D383SF739", issuer_id: "6053b7fe-68a8-4acb-89be-165aa6465141", key_filepath: "./AuthKey_D383SF739.p8")
          apps = app_store_connect_api(path: "/v1/apps?limit=200", paginate: true) # apps["data"] lists every app',
          'app_store_connect_api(
            http_method: "PATCH",
            path: "/v1/betaGroups/123",
            body: { data: { type: "betaGroups", id: "123", attributes: { name: "QA" } } },
            api_key_path: "fastlane/api_key.json"
          )'
        ]
      end

      def self.category
        :app_store_connect
      end
    end
  end
end
