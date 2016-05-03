module Fastlane
  module Actions
    class UpdateUrbanAirshipConfigurationAction < Action
      def self.run(params)
        require "plist"

        begin
          path = File.expand_path(params[:plist_path])
          plist = Plist.parse_xml(path)
          plist['developmentAppKey'] = params[:development_app_key]
          plist['developmentAppSecret'] = params[:development_app_secret]
          plist['productionAppKey'] = params[:production_app_key]
          plist['productionAppSecret'] = params[:production_app_secret]
          plist['detectProvisioningMode'] = params[:detect_provisioning_mode]
          new_plist = plist.to_plist
          File.write(path, new_plist)
        rescue => ex
          UI.error(ex)
          UI.error("Unable to update Urban Airship configuration for plist file at '#{path}'")
        end
      end

      def self.description
        "Set the Urban Airship plist configuration values"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       env_name: "URBAN_AIRSHIP_PLIST_PATH",
                                       description: "Path to Urban Airship configuration Plist",
                                       verify_block: proc do |value|
                                         raise "Could not find Urban Airship plist file".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :development_app_key,
                                       env_name: "URBAN_AIRSHIP_DEVELOPMENT_APP_KEY",
                                       description: "The development app key"),
          FastlaneCore::ConfigItem.new(key: :development_app_secret,
                                       env_name: "URBAN_AIRSHIP_DEVELOPMENT_APP_SECRET",
                                       description: "The development app secret"),
          FastlaneCore::ConfigItem.new(key: :production_app_key,
                                       env_name: "URBAN_AIRSHIP_PRODUCTION_APP_KEY",
                                       description: "The production app key"),
          FastlaneCore::ConfigItem.new(key: :production_app_secret,
                                       env_name: "URBAN_AIRSHIP_PRODUCTION_APP_SECRET",
                                       description: "The production app secret"),
          FastlaneCore::ConfigItem.new(key: :detect_provisioning_mode,
                                       env_name: "URBAN_AIRSHIP_DETECT_PROVISIONING_MODE",
                                       is_string: false,
                                       optional: true,
                                       default_value: true,
                                       description: "Automatically detect provisioning mode")
        ]
      end

      def self.authors
        ["kcharwood"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
