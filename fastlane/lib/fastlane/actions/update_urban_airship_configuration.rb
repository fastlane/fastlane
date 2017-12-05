module Fastlane
  module Actions
    class UpdateUrbanAirshipConfigurationAction < Action
      def self.run(params)
        require "plist"

        begin
          path = File.expand_path(params[:plist_path])
          plist = Plist.parse_xml(path)
          plist['developmentAppKey'] = params[:development_app_key] unless params[:development_app_key].nil?
          plist['developmentAppSecret'] = params[:development_app_secret] unless params[:development_app_secret].nil?
          plist['productionAppKey'] = params[:production_app_key] unless params[:production_app_key].nil?
          plist['productionAppSecret'] = params[:production_app_secret] unless params[:production_app_secret].nil?
          plist['detectProvisioningMode'] = params[:detect_provisioning_mode] unless params[:detect_provisioning_mode].nil?
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

      def self.details
        "This action updates the AirshipConfig.plist need to configure the Urban Airship SDK at runtime, allowing keys and secrets to easily be set for Enterprise and Production versions of the application."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       env_name: "URBAN_AIRSHIP_PLIST_PATH",
                                       description: "Path to Urban Airship configuration Plist",
                                       verify_block: proc do |value|
                                         UI.user_errror!("Could not find Urban Airship plist file") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :development_app_key,
                                       optional: true,
                                       env_name: "URBAN_AIRSHIP_DEVELOPMENT_APP_KEY",
                                       sensitive: true,
                                       description: "The development app key"),
          FastlaneCore::ConfigItem.new(key: :development_app_secret,
                                       optional: true,
                                       env_name: "URBAN_AIRSHIP_DEVELOPMENT_APP_SECRET",
                                       sensitive: true,
                                       description: "The development app secret"),
          FastlaneCore::ConfigItem.new(key: :production_app_key,
                                       optional: true,
                                       env_name: "URBAN_AIRSHIP_PRODUCTION_APP_KEY",
                                       sensitive: true,
                                       description: "The production app key"),
          FastlaneCore::ConfigItem.new(key: :production_app_secret,
                                       optional: true,
                                       env_name: "URBAN_AIRSHIP_PRODUCTION_APP_SECRET",
                                       sensitive: true,
                                       description: "The production app secret"),
          FastlaneCore::ConfigItem.new(key: :detect_provisioning_mode,
                                       env_name: "URBAN_AIRSHIP_DETECT_PROVISIONING_MODE",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true,
                                       description: "Automatically detect provisioning mode")
        ]
      end

      def self.authors
        ["kcharwood"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'update_urban_airship_configuration(
            plist_path: "AirshipConfig.plist",
            production_app_key: "PRODKEY",
            production_app_secret: "PRODSECRET"
          )'
        ]
      end

      def self.category
        :push
      end
    end
  end
end
