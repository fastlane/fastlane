module Fastlane
  module Actions
    module SharedValues
      APP_STORE_LATEST_BUILD_NUMBER = :APP_STORE_LATEST_BUILD_NUMBER
    end

    class AppStoreBuildNumberAction < Action
      def self.run(params)
        build_number = AppStoreBuildInfoAction.run(params)
        Actions.lane_context[SharedValues::APP_STORE_LATEST_BUILD_NUMBER] = build_number
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns the current build_number of either live or edit version"
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
        [
          FastlaneCore::ConfigItem.new(key: :initial_build_number,
                                       env_name: "INITIAL_BUILD_NUMBER",
                                       description: "sets the build number to given value if no build is in current train",
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       short_option: "-a",
                                       env_name: "FASTLANE_APP_IDENTIFIER",
                                       description: "The bundle identifier of your app",
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "ITUNESCONNECT_USER",
                                       description: "Your Apple ID Username",
                                       default_value: user,
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-k",
                                       env_name: "APPSTORE_BUILD_NUMBER_LIVE_TEAM_ID",
                                       description: "The ID of your iTunes Connect team if you're in multiple teams",
                                       optional: true,
                                       is_string: false, # as we also allow integers, which we convert to strings anyway
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :live,
                                       short_option: "-l",
                                       env_name: "APPSTORE_BUILD_NUMBER_LIVE",
                                       description: "Query the live version (ready-for-sale)",
                                       optional: true,
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "LATEST_VERSION",
                                       description: "The version number whose latest build number we want",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       short_option: "-j",
                                       env_name: "APPSTORE_PLATFORM",
                                       description: "The platform to use (optional)",
                                       optional: true,
                                       is_string: true,
                                       default_value: "ios",
                                       verify_block: proc do |value|
                                         UI.user_error!("The platform can only be ios, appletvos, or osx") unless %('ios', 'appletvos', 'osx').include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-e",
                                       env_name: "LATEST_TESTFLIGHT_BUILD_NUMBER_TEAM_NAME",
                                       description: "The name of your iTunes Connect team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                       end)
        ]
      end

      def self.output
        [
          ['APP_STORE_LATEST_BUILD_NUMBER', 'The latest build number of either live or testflight version']
        ]
      end

      def self.details
        [
          "Returns the current build number of either the live or testflight version - it is useful for getting the build_number of the current or ready-for-sale app version, and it also works on non-live testflight version.",
          "If you need to handle more build-trains please see `latest_testflight_build_number`."
        ].join("\n")
      end

      def self.example_code
        [
          'app_store_build_number',
          'app_store_build_number(
            app_identifier: "app.identifier",
            username: "user@host.com"
          )',
          'app_store_build_number(
            live: false,
            app_identifier: "app.identifier",
            version: "1.2.9"
          )'
        ]
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.category
        :misc
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
