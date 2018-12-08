require 'credentials_manager'

module Fastlane
  module Actions
    class RegisterDevicesAction < Action
      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.run(params)
        require 'spaceship'

        devices = params[:devices]
        devices_file = params[:devices_file]

        mac = params[:platform] == "mac"

        credentials = CredentialsManager::AccountManager.new(user: params[:username])
        Spaceship.login(credentials.user, credentials.password)
        Spaceship.select_team

        UI.message("Fetching list of currently registered devices...")
        existing_devices = Spaceship::Device.all(mac: mac)

        if devices
          device_objs = devices.map do |k, v|
            next if existing_devices.map(&:udid).include?(v)
            try_create_device(name: k, udid: v, mac: mac)
          end
        elsif devices_file
          require 'csv'

          devices_file = CSV.read(File.expand_path(File.join(devices_file)), col_sep: "\t")
          UI.user_error!("Please provide a file according to the Apple Sample UDID file (https://devimages.apple.com.edgekey.net/downloads/devices/Multiple-Upload-Samples.zip)") unless devices_file.first == ['Device ID', 'Device Name']

          device_objs = devices_file.drop(1).map do |device|
            next if existing_devices.map(&:udid).include?(device[0])

            UI.user_error!("Invalid device line, please provide a file according to the Apple Sample UDID file (http://devimages.apple.com/downloads/devices/Multiple-Upload-Samples.zip)") unless device.count == 2

            try_create_device(name: device[1], udid: device[0], mac: mac)
          end
        else
          UI.user_error!("You must pass either a valid `devices` or `devices_file`. Please check the readme.")
        end

        UI.success("Successfully registered new devices.")
        return device_objs
      end

      def self.try_create_device(name: nil, udid: nil, mac: false)
        Spaceship::Device.create!(name: name, udid: udid, mac: mac)
      rescue => ex
        UI.error(ex.to_s)
        UI.crash!("Failed to register new device (name: #{name}, UDID: #{udid})")
      end

      def self.description
        "Registers new devices to the Apple Dev Portal"
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
        platform = Actions.lane_context[Actions::SharedValues::PLATFORM_NAME].to_s

        [
          FastlaneCore::ConfigItem.new(key: :devices,
                                       env_name: "FL_REGISTER_DEVICES_DEVICES",
                                       description: "A hash of devices, with the name as key and the UDID as value",
                                       is_string: false,
                                       type: Hash,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :devices_file,
                                       env_name: "FL_REGISTER_DEVICES_FILE",
                                       description: "Provide a path to a file with the devices to register. For the format of the file see the examples",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find file '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                     env_name: "REGISTER_DEVICES_TEAM_ID",
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                       default_value_dynamic: true,
                                     description: "The ID of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value.to_s
                                     end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       env_name: "REGISTER_DEVICES_TEAM_NAME",
                                       description: "The name of your Developer Portal team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "DELIVER_USER",
                                       description: "Optional: Your Apple ID",
                                       default_value: user,
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "REGISTER_DEVICES_PLATFORM",
                                       description: "The platform to use (optional)",
                                       optional: true,
                                       default_value: platform.empty? ? "ios" : platform,
                                       verify_block: proc do |value|
                                         UI.user_error!("The platform can only be ios or mac") unless %('ios', 'mac').include?(value)
                                       end)
        ]
      end

      def self.details
        [
          "This will register iOS/Mac devices with the Developer Portal so that you can include them in your provisioning profiles.",
          "This is an optimistic action, in that it will only ever add new devices to the member center, and never remove devices. If a device which has already been registered within the member center is not passed to this action, it will be left alone in the member center and continue to work.",
          "The action will connect to the Apple Developer Portal using the username you specified in your `Appfile` with `apple_id`, but you can override it using the `username` option, or by setting the env variable `ENV['DELIVER_USER']`."
        ].join("\n")
      end

      def self.author
        "lmirosevic"
      end

      def self.example_code
        [
          'register_devices(
            devices: {
              "Luka iPhone 6" => "1234567890123456789012345678901234567890",
              "Felix iPad Air 2" => "abcdefghijklmnopqrstvuwxyzabcdefghijklmn"
            }
          ) # Simply provide a list of devices as a Hash',
          'register_devices(
            devices_file: "./devices.txt"
          ) # Alternatively provide a standard UDID export .txt file, see the Apple Sample (http://devimages.apple.com/downloads/devices/Multiple-Upload-Samples.zip)',
          'register_devices(
            devices_file: "./devices.txt", # You must pass in either `devices_file` or `devices`.
            team_id: "XXXXXXXXXX",         # Optional, if you"re a member of multiple teams, then you need to pass the team ID here.
            username: "luka@goonbee.com"   # Optional, lets you override the Apple Member Center username.
          )',
          'register_devices(
            devices: {
              "Luka MacBook" => "12345678-1234-1234-1234-123456789012",
              "Felix MacBook Pro" => "ABCDEFGH-ABCD-ABCD-ABCD-ABCDEFGHIJKL"
            },
            platform: "mac"
          ) # Register devices for Mac'
        ]
      end

      def self.category
        :code_signing
      end
    end
  end
end
