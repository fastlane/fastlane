module Fastlane
  module Actions
    module SharedValues
      APP_STORE_CONNECT_API_KEY = :APP_STORE_CONNECT_API_KEY
    end

    class AppStoreConnectApiKeyAction < Action
      def self.run(options)
        key_id = options[:id]
        issuer_id = options[:issuer_id]
        filepath = options[:filepath]

        key = {
          key_id: key_id,
          issuer_id: issuer_id,
          key: File.binread(filepath)
        }

        Actions.lane_context[SharedValues::APP_STORE_CONNECT_API_KEY] = key

        return key
      end

      def self.description
        "Load the App Store Connect API token to use in other fastlane tools and actions"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :id,
                                       env_name: "APP_STORE_CONNECT_API_KEY_ID",
                                       description: "App Store Connect API key ID"),
          FastlaneCore::ConfigItem.new(key: :issuer_id,
                                       env_name: "APP_STORE_CONNECT_API_KEY_ISSUER_ID",
                                       description: "App Store Connect API key issuer ID"),
          FastlaneCore::ConfigItem.new(key: :filepath,
                                       env_name: "APP_STORE_CONNECT_API_KEY_FILEPATH",
                                       description: "Path to your App Store Connect API key p8 file",
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find key p8 file at path '#{value}'") unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        [
          ['APP_STORE_CONNECT_API_KEY', 'The App Store Connect API key used for authorization requests']
        ]
      end

      def self.author
        ["joshdholtz"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.details
        [
          "Something"
        ].join("\n")
      end

      def self.example_code
        [
          'app_store_connect_api_key(
            id: "D83848D23",
            issuer_id: "227b0bbf-ada8-458c-9d62-3d8022b7d07f",
            filepath: "D83848D23.p8"
          )'
        ]
      end

      def self.category
        :app_store_connect
      end
    end
  end
end
