require 'credentials_manager'

module Fastlane
  module Actions
    class RegisterDevicesAction < Action
      UDID_REGEXP = /^\h{40}$/

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.run(params)
        require 'spaceship'

        devices = params[:devices]
        devices_file = params[:devices_file]

        credentials = CredentialsManager::AccountManager.new(user: params[:username])
        Spaceship.login(credentials.user, credentials.password)
        ENV["FASTLANE_TEAM_ID"] = params[:team_id]
        Spaceship.select_team

        if devices
          device_objs = devices.map do |k, v|
            UI.user_error!("Passed invalid UDID: #{v} for device: #{k}") unless UDID_REGEXP =~ v
            Spaceship::Device.create!(name: k, udid: v)
          end
        elsif devices_file
          require 'csv'

          devices_file = CSV.read(File.expand_path(File.join(devices_file)), col_sep: "\t")
          UI.user_error!("Please provide a file according to the Apple Sample UDID file (https://devimages.apple.com.edgekey.net/downloads/devices/Multiple-Upload-Samples.zip)") unless devices_file.first == ['Device ID', 'Device Name']

          UI.message("Fetching list of currently registered devices...")
          existing_devices = Spaceship::Device.all

          device_objs = devices_file.drop(1).map do |device|
            next if existing_devices.map(&:udid).include?(device[0])

            UI.user_error!("Invalid device line, please provide a file according to the Apple Sample UDID file (https://devimages.apple.com.edgekey.net/downloads/devices/Multiple-Upload-Samples.zip)") unless device.count == 2
            UI.user_error!("Passed invalid UDID: #{device[0]} for device: #{device[1]}") unless UDID_REGEXP =~ device[0]

            Spaceship::Device.create!(name: device[1], udid: device[0])
          end
        else
          UI.user_error!("You must pass either a valid `devices` or `devices_file`. Please check the readme.")
        end

        UI.success("Successfully registered new devices.")
        return device_objs
      end

      def self.description
        "Registers new devices to the Apple Dev Portal"
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :devices,
                                       env_name: "FL_REGISTER_DEVICES_DEVICES",
                                       description: "A hash of devices, with the name as key and the UDID as value",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :devices_file,
                                       env_name: "FL_REGISTER_DEVICES_FILE",
                                       description: "Provide a path to the devices to register",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find file '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       env_name: "FASTLANE_TEAM_ID",
                                       description: "optional: Your team ID",
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "DELIVER_USER",
                                       description: "Optional: Your Apple ID",
                                       default_value: user)
        ]
      end

      def self.author
        "lmirosevic"
      end
    end
  end
end
