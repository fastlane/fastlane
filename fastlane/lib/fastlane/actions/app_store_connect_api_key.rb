module Fastlane
  module Actions
    module SharedValues
      APP_STORE_CONNECT_API_KEY = :APP_STORE_CONNECT_API_KEY
    end

    class AppStoreConnectApiKeyAction < Action
      def self.run(options)
        key_id = options[:key_id]
        issuer_id = options[:issuer_id]
        key_content = options[:key_content]
        filepath = options[:key_filepath]
        duration = options[:duration]
        in_house = options[:in_house]

        if key_content.nil? && filepath.nil?
          UI.user_error!(":key_content or :key_filepath is required")
        end

        key = {
          key_id: key_id,
          issuer_id: issuer_id,
          key: key_content || File.binread(filepath),
          duration: duration,
          in_house: in_house
        }

        Actions.lane_context[SharedValues::APP_STORE_CONNECT_API_KEY] = key

        return key
      end

      def self.description
        "Load the App Store Connect API token to use in other fastlane tools and actions"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :key_id,
                                       env_name: "APP_STORE_CONNECT_API_KEY_KEY_ID",
                                       description: "The key ID"),
          FastlaneCore::ConfigItem.new(key: :issuer_id,
                                       env_name: "APP_STORE_CONNECT_API_KEY_ISSUER_ID",
                                       description: "The issuer ID"),
          FastlaneCore::ConfigItem.new(key: :key_filepath,
                                       env_name: "APP_STORE_CONNECT_API_KEY_KEY_FILEPATH",
                                       description: "The path to the key p8 file",
                                       optional: true,
                                       conflicting_options: [:key_content],
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find key p8 file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :key_content,
                                       env_name: "APP_STORE_CONNECT_API_KEY_KEY",
                                       description: "The content of the key p8 file",
                                       optional: true,
                                       conflicting_options: [:filepath]),
          FastlaneCore::ConfigItem.new(key: :duration,
                                       env_name: "APP_STORE_CONNECT_API_KEY_DURATION",
                                       description: "The token session duration",
                                       optional: true,
                                       type: Integer),
          FastlaneCore::ConfigItem.new(key: :in_house,
                                       env_name: "APP_STORE_CONNECT_API_KEY_IN_HOUSE",
                                       description: "Is App Store or Enterprise (in house) team? App Store Connect API cannot not determine this on its own (yet)",
                                       optional: true,
                                       type: Boolean)
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
