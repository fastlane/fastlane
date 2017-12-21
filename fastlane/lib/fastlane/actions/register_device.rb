require 'credentials_manager'

module Fastlane
  module Actions
    class RegisterDeviceAction < Action
      UDID_REGEXP = /^\h{40}$/

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.run(params)
        require 'spaceship'

        name = params[:name]
        udid = params[:udid]

        credentials = CredentialsManager::AccountManager.new(user: params[:username])
        Spaceship.login(credentials.user, credentials.password)
        Spaceship.select_team

        UI.user_error!("Passed invalid UDID: #{udid} for device: #{name}") unless UDID_REGEXP =~ udid
        Spaceship::Device.create!(name: name, udid: udid)

        UI.success("Successfully registered new device")
        return udid
      end

      def self.description
        "Registers a new device to the Apple Dev Portal"
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "FL_REGISTER_DEVICE_NAME",
                                       description: "Provide the name of the device to register as"),
          FastlaneCore::ConfigItem.new(key: :udid,
                                       env_name: "FL_REGISTER_DEVICE_UDID",
                                       description: "Provide the UDID of the device to register as"),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                     env_name: "REGISTER_DEVICE_TEAM_ID",
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     description: "The ID of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value.to_s
                                     end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       env_name: "REGISTER_DEVICE_TEAM_NAME",
                                       description: "The name of your Developer Portal team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "DELIVER_USER",
                                       description: "Optional: Your Apple ID",
                                       default_value: user)
        ]
      end

      def self.details
        [
          "This will register an iOS device with the Developer Portal so that you can include it in your provisioning profiles.",
          "This is an optimistic action, in that it will only ever add a device to the member center. If the device has already been registered within the member center, it will be left alone in the member center.",
          "The action will connect to the Apple Developer Portal using the username you specified in your `Appfile` with `apple_id`, but you can override it using the `username` option."
        ].join("\n")
      end

      def self.author
        "pvinis"
      end

      def self.example_code
        [
          'register_device(
            name: "Luka iPhone 6",
            udid: "1234567890123456789012345678901234567890"
          ) # Simply provide the name and udid of the device',
          'register_device(
            name: "Luka iPhone 6",
            udid: "1234567890123456789012345678901234567890",
            team_id: "XXXXXXXXXX",         # Optional, if you"re a member of multiple teams, then you need to pass the team ID here.
            username: "luka@goonbee.com"   # Optional, lets you override the Apple Member Center username.
          )'
        ]
      end

      def self.return_type
        :string
      end

      def self.category
        :code_signing
      end
    end
  end
end
