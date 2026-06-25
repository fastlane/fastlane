module Fastlane
  module Actions
    class UpdateAppAgeRatingAction < Action
      def self.description
        "Update your app's age rating on App Store Connect"
      end

      def self.details
        "Updates only the age rating of your app on App Store Connect without touching " \
          "any other metadata, screenshots, or binaries. Useful for CI pipelines that need " \
          "to update age ratings independently of an app release. Supports both API key " \
          "and Apple ID authentication."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :api_key_path,
            env_names: ["DELIVER_API_KEY_PATH", "APP_STORE_CONNECT_API_KEY_PATH"],
            description: "Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/)",
            optional: true,
            conflicting_options: %i[api_key],
            verify_block: proc do |value|
              UI.user_error!("Couldn't find API key JSON file at path '#{value}'") unless File.exist?(value)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :api_key,
            env_names: ["DELIVER_API_KEY", "APP_STORE_CONNECT_API_KEY"],
            description: "Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/)",
            optional: true,
            conflicting_options: %i[api_key_path],
            sensitive: true,
            type: Hash
          ),
          FastlaneCore::ConfigItem.new(
            key: :app_identifier,
            env_name: "DELIVER_APP_IDENTIFIER",
            description: "The bundle identifier of your app",
            optional: false,
            type: String,
            code_gen_sensitive: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :username,
            env_name: "DELIVER_USER",
            description: "Your Apple ID username",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :age_rating_config_path,
            env_name: "DELIVER_AGE_RATING_CONFIG_PATH",
            description: "Path to the JSON file containing the age rating configuration",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Age rating configuration file not found at: '#{value}'") unless File.exist?(value)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :team_id,
            env_name: "FASTLANE_TEAM_ID",
            description: "The ID of your App Store Connect team if you're in multiple teams",
            optional: true,
            type: String,
            code_gen_sensitive: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :team_name,
            env_name: "FASTLANE_TEAM_NAME",
            description: "The name of your App Store Connect team if you're in multiple teams",
            optional: true,
            type: String
          )
        ]
      end

      def self.run(params)
        require 'spaceship'
        require 'json'

        # Honour an API key that was set by app_store_connect_api_key earlier in the lane
        params[:api_key] ||= Actions.lane_context[SharedValues::APP_STORE_CONNECT_API_KEY]

        # Authenticate: API key takes priority, falls back to Apple ID session
        token = Spaceship::ConnectAPI::Token.from(
          hash: params[:api_key],
          filepath: params[:api_key_path]
        )

        if token
          UI.message("Creating authorization token for App Store Connect API")
          Spaceship::ConnectAPI.token = token
        else
          UI.message("Login to App Store Connect (#{params[:username]})")
          Spaceship::ConnectAPI.login(
            params[:username],
            nil,
            use_portal: false,
            use_tunes: true,
            team_id: params[:team_id],
            team_name: params[:team_name]
          )
        end

        # Find the app by bundle identifier
        app = Spaceship::ConnectAPI::App.find(params[:app_identifier])
        UI.user_error!("Could not find app with identifier '#{params[:app_identifier]}'") unless app

        # Fetch the editable app info
        app_info = app.fetch_edit_app_info
        unless app_info
          UI.user_error!(
            "Could not fetch editable app info for '#{params[:app_identifier]}'. " \
            "Ensure the app is in an editable state in App Store Connect."
          )
        end

        # Parse age rating config and map ITC keys to ASC keys
        config_json = parse_config(params[:age_rating_config_path])
        attributes  = build_attributes(config_json)

        # Fetch and update the age rating declaration
        age_rating = app_info.fetch_age_rating_declaration
        UI.user_error!("Could not fetch age rating declaration for '#{params[:app_identifier]}'") unless age_rating

        UI.message("Updating age rating for '#{params[:app_identifier]}'...")
        age_rating.update(attributes: attributes)
        UI.success("Successfully updated age rating for '#{params[:app_identifier]}'")

        true
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.example_code
        [
          '# Using App Store Connect API key (recommended for CI)
          update_app_age_rating(
            api_key_path: "fastlane/api_key.json",
            app_identifier: "com.example.app",
            age_rating_config_path: "fastlane/metadata/age_rating.json"
          )',
          '# Using Apple ID
          update_app_age_rating(
            username: "user@example.com",
            app_identifier: "com.example.app",
            age_rating_config_path: "fastlane/metadata/age_rating.json",
            team_id: "ABC123456"
          )',
          '# Using the api_key hash returned by app_store_connect_api_key action
          api_key = app_store_connect_api_key(
            key_id: "D383SF739",
            issuer_id: "6053b7fe-68a8-4acb-89be-165aa6465141",
            key_filepath: "./AuthKey_D383SF739.p8"
          )
          update_app_age_rating(
            api_key: api_key,
            app_identifier: "com.example.app",
            age_rating_config_path: "fastlane/metadata/age_rating.json"
          )'
        ]
      end

      def self.category
        :app_store_connect
      end

      def self.authors
        ["PratikPatil131"]
      end

      def self.return_value
        "Returns true if the age rating was successfully updated"
      end

      def self.is_supported?(platform) # rubocop:disable Naming/PredicateName
        # fastlane's Action interface mandates the method name `is_supported?`
        %i[ios mac tvos].include?(platform)
      end

      #####################################################
      # @!group Private helpers
      #####################################################

      def self.parse_config(config_path)
        JSON.parse(File.read(config_path))
      rescue JSON::ParserError => ex
        UI.user_error!("Invalid JSON in age rating configuration file '#{config_path}': #{ex.message}")
      rescue StandardError => ex
        UI.user_error!("Could not read age rating configuration file '#{config_path}': #{ex.message}")
      end
      private_class_method :parse_config

      def self.build_attributes(config_json)
        attributes = config_json.each_with_object({}) do |(key, value), attrs|
          new_key = Spaceship::ConnectAPI::AgeRatingDeclaration.map_key_from_itc(key)
          new_value = Spaceship::ConnectAPI::AgeRatingDeclaration.map_value_from_itc(new_key, value)
          attrs[new_key] = new_value
        end
        attributes, = Spaceship::ConnectAPI::AgeRatingDeclaration.map_deprecation_if_possible(attributes)
        attributes
      end
      private_class_method :build_attributes
    end
  end
end
