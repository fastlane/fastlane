module Fastlane
  module Actions
    module SharedValues
      LATEST_BUILD_NUMBER = :LATEST_BUILD_NUMBER
    end

    class AppStoreBuildNumberAction < Action
      def self.run(params)
        require 'spaceship'

        build_nr = get_build_number(params)

        # Convert build_nr to int (for legacy use) if no "." in string
        if build_nr.kind_of?(String) && !build_nr.include?(".")
          build_nr = build_nr.to_i
        end

        Actions.lane_context[SharedValues::LATEST_BUILD_NUMBER] = build_nr
      end

      def self.get_build_number(params)
        UI.message("Login to App Store Connect (#{params[:username]})")
        Spaceship::Tunes.login(params[:username])
        Spaceship::Tunes.select_team(team_id: params[:team_id], team_name: params[:team_name])
        UI.message("Login successful")

        app = Spaceship::Tunes::Application.find(params[:app_identifier], mac: params[:platform] == "osx")
        UI.user_error!("Could not find an app on App Store Connect with app_identifier: #{params[:app_identifier]}") unless app
        if params[:live]
          UI.message("Fetching the latest build number for live-version")
          UI.user_error!("Could not find a live-version of #{params[:app_identifier]} on iTC") unless app.live_version
          build_nr = app.live_version.current_build_number

          UI.message("Latest upload for live-version #{app.live_version.version} is build: #{build_nr}")

          return build_nr
        else
          version_number = params[:version]
          platform = params[:platform]

          # Create filter for get_builds with optional version number
          filter = { app: app.apple_id }
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
            return build_nr
          end

          # Let user know that build couldn't be found
          UI.important("Could not find a build for #{version_number_message} on #{platform_message} on App Store Connect")

          if params[:initial_build_number].nil?
            UI.user_error!("Could not find a build on App Store Connect - and 'initial_build_number' option is not set")
          else
            build_nr = params[:initial_build_number]
            UI.message("Using initial build number of #{build_nr}")
            return build_nr
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
                                       description: "The ID of your App Store Connect team if you're in multiple teams",
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
          ['LATEST_BUILD_NUMBER', 'The latest build number of either live or testflight version']
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
        :app_store_connect
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
