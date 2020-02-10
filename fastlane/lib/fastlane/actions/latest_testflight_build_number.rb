require 'credentials_manager'

module Fastlane
  module Actions
    module SharedValues
      LATEST_TESTFLIGHT_BUILD_NUMBER = :LATEST_TESTFLIGHT_BUILD_NUMBER
      LATEST_TESTFLIGHT_VERSION = :LATEST_TESTFLIGHT_VERSION
    end

    class LatestTestflightBuildNumberAction < Action
      def self.run(params)
        AppStoreBuildNumberAction.run(params)
        build_nr = Actions.lane_context[SharedValues::LATEST_BUILD_NUMBER]
        build_v = Actions.lane_context[SharedValues::LATEST_VERSION]
        Actions.lane_context[SharedValues::LATEST_TESTFLIGHT_BUILD_NUMBER] = build_nr
        Actions.lane_context[SharedValues::LATEST_TESTFLIGHT_VERSION] = build_v
        return build_nr
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Fetches most recent build number from TestFlight"
      end

      def self.details
        [
          "Provides a way to have `increment_build_number` be based on the latest build you uploaded to iTC.",
          "Fetches the most recent build number from TestFlight based on the version number. Provides a way to have `increment_build_number` be based on the latest build you uploaded to iTC."
        ].join("\n")
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :live,
                                       short_option: "-l",
                                       env_name: "CURRENT_BUILD_NUMBER_LIVE",
                                       description: "Query the live version (ready-for-sale)",
                                       optional: true,
                                       is_string: false,
                                       default_value: false),
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
                                         UI.user_error!("The platform can only be ios, osx, or appletvos") unless %('osx', ios', 'appletvos').include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :initial_build_number,
                                       env_name: "INITIAL_BUILD_NUMBER",
                                       description: "sets the build number to given value if no build is in current train",
                                       default_value: 1,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-k",
                                       env_name: "LATEST_TESTFLIGHT_BUILD_NUMBER_TEAM_ID",
                                       description: "The ID of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       is_string: false, # as we also allow integers, which we convert to strings anyway
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-e",
                                       env_name: "LATEST_TESTFLIGHT_BUILD_NUMBER_TEAM_NAME",
                                       description: "The name of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                       default_value_dynamic: true)
        ]
      end

      def self.output
        [
          ['LATEST_TESTFLIGHT_BUILD_NUMBER', 'The latest build number of the latest version of the app uploaded to TestFlight'],
          ['LATEST_TESTFLIGHT_VERSION', 'The version of the latest build number']
        ]
      end

      def self.return_value
        "Integer representation of the latest build number uploaded to TestFlight"
      end

      def self.return_type
        :int
      end

      def self.authors
        ["daveanderson"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'latest_testflight_build_number(version: "1.3")',
          'increment_build_number({
            build_number: latest_testflight_build_number + 1
          })'
        ]
      end

      def self.sample_return_value
        2
      end

      def self.category
        :app_store_connect
      end
    end
  end
end
