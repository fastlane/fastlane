module Fastlane
  module Actions
    module SharedValues
      DEVICES_FOR_APPLE_CERTIFICATE = :DEVICES_FOR_APPLE_CERTIFICATE
    end

    class RetrieveDevicesAction < Action
      def self.run(params)
        require 'spaceship'
        if (api_token = Spaceship::ConnectAPI::Token.from(hash: params[:api_key], filepath: params[:api_key_path]))
          UI.message("Creating authorization token for App Store Connect API")
          Spaceship::ConnectAPI.token = api_token
        elsif !Spaceship::ConnectAPI.token.nil?
          UI.message("Using existing authorization token for App Store Connect API")
        else
          UI.message("Login to App Store Connect (#{params[:username]})")
          credentials = CredentialsManager::AccountManager.new(user: params[:username])
          Spaceship::ConnectAPI.login(credentials.user, credentials.password, use_portal: true, use_tunes: false)
          UI.message("Login successful")
        end

        UI.message("Fetching list of currently registered devices...")
        existing_devices = Spaceship::ConnectAPI::Device.all.map { |ed| { name: ed.name, udid: ed.udid } }

        UI.success("Successfully retrieved the following devices")

        existing_devices.each do |ed|
          UI.message("UDID: #{ed[:udid]} | NAME: #{ed[:name]}")
        end

        Actions.lane_context[SharedValues::DEVICES_FOR_APPLE_CERTIFICATE] = existing_devices
        # sh "shellcommand ./path"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This action will retrieve a list of each device registered with Apple"
      end

      def self.details
        [
          "This action will retrieve a list of names and UDIDs of each device registered with your Apple Certificate.",
          "This list is exactly the same as the list used to compare against what is/isn't registered in the `register_device/s` action."
        ].join("\n")
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :api_key_path,
                                       env_names: ["FL_RETRIEVE_DEVICES_API_KEY_PATH", "APP_STORE_CONNECT_API_KEY_PATH"],
                                       description: "Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)",
                                       optional: true,
                                       conflicting_options: [:api_key],
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find API key JSON file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_names: ["FL_RETRIEVE_DEVICES_API_KEY", "APP_STORE_CONNECT_API_KEY"],
                                       description: "Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)",
                                       type: Hash,
                                       default_value: Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY],
                                       default_value_dynamic: true,
                                       optional: true,
                                       sensitive: true,
                                       conflicting_options: [:api_key_path]),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "DELIVER_USER",
                                       description: "Optional: Your Apple ID",
                                       optional: true,
                                       default_value: user,
                                       default_value_dynamic: true)
        ]
      end

      def self.output
        [
          ['DEVICES_FOR_APPLE_CERTIFICATE', 'A hash with the Name and UDID of each device registered with Apple']
        ]
      end

      def self.return_value
      end

      def self.authors
        ["builtbyproxy"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.category
        :misc
      end
    end
  end
end
