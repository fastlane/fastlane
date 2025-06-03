require 'ostruct'

module Fastlane
  module Actions
    module SharedValues
      LATEST_BUILD_NUMBER = :LATEST_BUILD_NUMBER
      LATEST_VERSION = :LATEST_VERSION
    end

    class AppStoreBuildNumberAction < Action
      def self.run(params)
        build_v, build_nr = get_build_version_and_number(params)

        Actions.lane_context[SharedValues::LATEST_BUILD_NUMBER] = build_nr
        Actions.lane_context[SharedValues::LATEST_VERSION] = build_v

        return build_nr
      end

      def self.get_build_version_and_number(params)
        require 'spaceship'

        result = get_build_info(params)
        build_nr = result.build_nr

        # Convert build_nr to int (for legacy use) if no "." in string
        if build_nr.kind_of?(String) && !build_nr.include?(".")
          build_nr = build_nr.to_i
        end

        return result.build_v, build_nr
      end

      def self.get_build_info(params)
        # Prompts select team if multiple teams and none specified
        if (api_token = Spaceship::ConnectAPI::Token.from(hash: params[:api_key], filepath: params[:api_key_path]))
          UI.message("Creating authorization token for App Store Connect API")
          Spaceship::ConnectAPI.token = api_token
        elsif !Spaceship::ConnectAPI.token.nil?
          UI.message("Using existing authorization token for App Store Connect API")
        else
          # Username is now optional since addition of App Store Connect API Key
          # Force asking for username to prompt user if not already set
          params.fetch(:username, force_ask: true)

          UI.message("Login to App Store Connect (#{params[:username]})")
          Spaceship::ConnectAPI.login(params[:username], use_portal: false, use_tunes: true, tunes_team_id: params[:team_id], team_name: params[:team_name])
          UI.message("Login successful")
        end

        platform = Spaceship::ConnectAPI::Platform.map(params[:platform])

        app = Spaceship::ConnectAPI::App.find(params[:app_identifier])
        UI.user_error!("Could not find an app on App Store Connect with app_identifier: #{params[:app_identifier]}") unless app
        if params[:live]
          UI.message("Fetching the latest build number for live-version")
          live_version = app.get_live_app_store_version(platform: platform)

          UI.user_error!("Could not find a live-version of #{params[:app_identifier]} on App Store Connect") unless live_version
          build_nr = live_version.build.version

          UI.message("Latest upload for live-version #{live_version.version_string} is build: #{build_nr}")

          return OpenStruct.new({ build_nr: build_nr, build_v: live_version.version_string })
        else
          version_number = params[:version]
          platform = params[:platform]

          # Create filter for get_builds with optional version number
          filter = { app: app.id }
          if version_number
            filter["preReleaseVersion.version"] = version_number
            version_number_message = "version #{version_number}"
          else
            version_number_message = "any version"
          end

          if platform
            filter["preReleaseVersion.platform"] = Spaceship::ConnectAPI::Platform.map(platform)
            platform_message = "#{platform} platform"
          else
            platform_message = "any platform"
          end

          UI.message("Fetching the latest build number for #{version_number_message}")

          # Get latest build for optional version number and return build number if found
          build = Spaceship::ConnectAPI.get_builds(filter: filter, sort: "-uploadedDate", includes: "preReleaseVersion", limit: 1).first
          if build
            build_nr = build.version
            UI.message("Latest upload for version #{build.app_version} on #{platform_message} is build: #{build_nr}")
            return OpenStruct.new({ build_nr: build_nr, build_v: build.app_version })
          end

          # Let user know that build couldn't be found
          UI.important("Could not find a build for #{version_number_message} on #{platform_message} on App Store Connect")

          if params[:initial_build_number].nil?
            UI.user_error!("Could not find a build on App Store Connect - and 'initial_build_number' option is not set")
          else
            build_nr = params[:initial_build_number]
            UI.message("Using initial build number of #{build_nr}")
            return OpenStruct.new({ build_nr: build_nr, build_v: version_number })
          end
        end
      end

      def self.order_versions(versions)
        versions.map(&:to_s).sort_by { |v| Gem::Version.new(v) }
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
          FastlaneCore::ConfigItem.new(key: :api_key_path,
                                       env_names: ["APPSTORE_BUILD_NUMBER_API_KEY_PATH", "APP_STORE_CONNECT_API_KEY_PATH"],
                                       description: "Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)",
                                       optional: true,
                                       conflicting_options: [:api_key],
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find API key JSON file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_names: ["APPSTORE_BUILD_NUMBER_API_KEY", "APP_STORE_CONNECT_API_KEY"],
                                       description: "Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-hash-option)",
                                       type: Hash,
                                       default_value: Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY],
                                       default_value_dynamic: true,
                                       optional: true,
                                       sensitive: true,
                                       conflicting_options: [:api_key_path]),
          FastlaneCore::ConfigItem.new(key: :initial_build_number,
                                       env_name: "INITIAL_BUILD_NUMBER",
                                       description: "sets the build number to given value if no build is in current train",
                                       skip_type_validation: true), # as we also allow integers, which we convert to strings anyway
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
                                       optional: true,
                                       default_value: user,
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-k",
                                       env_name: "APPSTORE_BUILD_NUMBER_LIVE_TEAM_ID",
                                       description: "The ID of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       skip_type_validation: true, # as we also allow integers, which we convert to strings anyway
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
                                       type: Boolean,
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
                                       default_value: "ios",
                                       verify_block: proc do |value|
                                         UI.user_error!("The platform can only be ios, appletvos/tvos, xros or osx") unless %w(ios appletvos tvos xros osx).include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-e",
                                       env_name: "LATEST_TESTFLIGHT_BUILD_NUMBER_TEAM_NAME",
                                       description: "The name of your App Store Connect team if you're in multiple teams",
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
          ['LATEST_BUILD_NUMBER', 'The latest build number of either live or testflight version'],
          ['LATEST_VERSION', 'The version of the latest build number']
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
          )',
          'api_key = app_store_connect_api_key(
            key_id: "MyKeyID12345",
            issuer_id: "00000000-0000-0000-0000-000000000000",
            key_filepath: "./AuthKey.p8"
          )
          build_num = app_store_build_number(
            api_key: api_key
          )'
        ]
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.category
        :app_store_connect
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
