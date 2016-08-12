require 'credentials_manager'

module Fastlane
  module Actions
    module SharedValues
      LATEST_TESTFLIGHT_BUILD_NUMBER = :LATEST_TESTFLIGHT_BUILD_NUMBER
    end

    class LatestTestflightBuildNumberAction < Action
      def self.run(params)
        require 'spaceship'

        credentials = CredentialsManager::AccountManager.new(user: params[:username])
        Spaceship::Tunes.login(credentials.user, credentials.password)
        ENV["FASTLANE_TEAM_ID"] = params[:team_id]
        Spaceship::Tunes.select_team
        app = Spaceship::Tunes::Application.find(params[:app_identifier])

        version_number = params[:version]
        unless version_number
          # Automatically fetch the latest version in testflight
          begin
            testflight_version = app.build_trains.keys.last
          rescue
            UI.user_error!("could not find any versions on iTC - and 'version' option is not set") unless params[:version]
            testflight_version = params[:version]
          end
          if testflight_version
            version_number = testflight_version
          else
            UI.message("You have to specify a new version number: ")
            version_number = STDIN.gets.strip
          end
        end

        UI.message("Fetching the latest build number for version #{version_number}")

        begin
          train = app.build_trains[version_number]
          build_number = train.builds.map(&:build_version).map(&:to_i).sort.last
        rescue
          UI.user_error!("could not find a build on iTC - and 'initial_build_number' option is not set") unless params[:initial_build_number]
          build_number = params[:initial_build_number]
        end

        UI.message("Latest upload is build number: #{build_number}")
        Actions.lane_context[SharedValues::LATEST_TESTFLIGHT_BUILD_NUMBER] = build_number
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Fetches most recent build number from TestFlight"
      end

      def self.details
        "Provides a way to have increment_build_number be based on the latest build you uploaded to iTC."
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       short_option: "-a",
                                       env_name: "FASTLANE_APP_IDENTIFIER",
                                       description: "The bundle identifier of your app",
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "ITUNESCONNECT_USER",
                                       description: "Your Apple ID Username",
                                       default_value: user),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "LATEST_VERSION",
                                       description: "The version number whose latest build number we want",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :initial_build_number,
                                       env_name: "INITIAL_BUILD_NUMBER",
                                       description: "sets the build number to given value if no build is in current train",
                                       default_value: 1,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       env_name: "FASTLANE_TEAM_ID",
                                       description: "Your team ID if you're in multiple teams",
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       optional: true)
        ]
      end

      def self.output
        [
          ['LATEST_TESTFLIGHT_BUILD_NUMBER', 'The latest build number of the latest version of the app uploaded to TestFlight']
        ]
      end

      def self.return_value
        "Integer representation of the latest build number uploaded to TestFlight"
      end

      def self.authors
        ["daveanderson"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
