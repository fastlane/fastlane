module Fastlane
  module Actions
    class SetChangelogAction < Action
      def self.run(params)
        require 'spaceship'

        # Team selection passed though FASTLANE_ITC_TEAM_ID and FASTLANE_ITC_TEAM_NAME environment variables
        # Prompts select team if multiple teams and none specified
        if (api_token = Spaceship::ConnectAPI::Token.from(hash: params[:api_key], filepath: params[:api_key_path]))
          UI.message("Creating authorization token for App Store Connect API")
          Spaceship::ConnectAPI.token = api_token
        elsif !Spaceship::ConnectAPI.token.nil?
          UI.message("Using existing authorization token for App Store Connect API")
        else
          UI.message("Login to App Store Connect (#{params[:username]})")
          Spaceship::ConnectAPI.login(params[:username], use_portal: false, use_tunes: true, tunes_team_id: params[:team_id], team_name: params[:team_name])
          UI.message("Login successful")
        end

        app = Spaceship::ConnectAPI::App.find(params[:app_identifier])
        UI.user_error!("Couldn't find app with identifier #{params[:app_identifier]}") if app.nil?

        version_number = params[:version]
        platform = Spaceship::ConnectAPI::Platform.map(params[:platform])

        unless version_number
          # Automatically fetch the latest version
          UI.message("Fetching the latest version for this app")
          edit_version = app.get_edit_app_store_version(platform: platform)
          if edit_version
            version_number = edit_version.version_string
          else
            UI.message("You have to specify a new version number: ")
            version_number = STDIN.gets.strip
          end
        end

        UI.message("Going to update version #{version_number}")

        changelog = params[:changelog]
        unless changelog
          path = default_changelog_path
          UI.message("Looking for changelog in '#{path}'...")
          if File.exist?(path)
            changelog = File.read(path)
          else
            UI.error("Couldn't find changelog.txt")
            UI.message("Please enter the changelog here:")
            changelog = STDIN.gets
          end
        end

        UI.important("Going to update the changelog to:\n\n#{changelog}\n\n")

        edit_version = app.get_edit_app_store_version(platform: platform)
        if edit_version
          if edit_version.version_string != version_number
            # Version is already there, make sure it matches the one we want to create
            UI.message("Changing existing version number from '#{edit_version.version_string}' to '#{version_number}'")
            edit_version = edit_version.update(attributes: {
              versionString: version_number
            })
          else
            UI.message("Updating changelog for existing version #{edit_version.version_string}")
          end
        else
          UI.message("Creating the new version: #{version_number}")
          attributes = { versionString: version_number, platform: platform }
          edit_version = Spaceship::ConnectAPI.post_app_store_version(app_id: app.id, attributes: attributes).first
        end

        localizations = edit_version.get_app_store_version_localizations
        localizations.each do |localization|
          UI.message("Updating changelog for the '#{localization.locale}'")
          localization.update(attributes: {
            whatsNew: changelog
          })
        end

        UI.success("👼  Successfully pushed the new changelog to for #{edit_version.version_string}")
      end

      def self.default_changelog_path
        File.join(FastlaneCore::FastlaneFolder.path.to_s, 'changelog.txt')
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set the changelog for all languages on App Store Connect"
      end

      def self.details
        [
          "This is useful if you have only one changelog for all languages.",
          "You can store the changelog in `#{default_changelog_path}` and it will automatically get loaded from there. This integration is useful if you support e.g. 10 languages and want to use the same \"What's new\"-text for all languages.",
          "Defining the version is optional. _fastlane_ will try to automatically detect it if you don't provide one."
        ].join("\n")
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :api_key_path,
                                     env_names: ["FL_SET_CHANGELOG_API_KEY_PATH", "APP_STORE_CONNECT_API_KEY_PATH"],
                                     description: "Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)",
                                     optional: true,
                                     conflicting_options: [:api_key],
                                     verify_block: proc do |value|
                                       UI.user_error!("Couldn't find API key JSON file at path '#{value}'") unless File.exist?(value)
                                     end),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                     env_names: ["FL_SET_CHANGELOG_API_KEY", "APP_STORE_CONNECT_API_KEY"],
                                     description: "Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-hash-option)",
                                     type: Hash,
                                     default_value: Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY],
                                     default_value_dynamic: true,
                                     optional: true,
                                     sensitive: true,
                                     conflicting_options: [:api_key_path]),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "FASTLANE_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                     default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "FASTLANE_USERNAME",
                                     description: "Your Apple ID Username",
                                     optional: true,
                                     default_value: user,
                                     default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_SET_CHANGELOG_VERSION",
                                       description: "The version number to create/update",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :changelog,
                                       env_name: "FL_SET_CHANGELOG_CHANGELOG",
                                       description: "Changelog text that should be uploaded to App Store Connect",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-k",
                                       env_name: "FL_SET_CHANGELOG_TEAM_ID",
                                       description: "The ID of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       skip_type_validation: true, # as we also allow integers, which we convert to strings anyway
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-e",
                                       env_name: "FL_SET_CHANGELOG_TEAM_NAME",
                                       description: "The name of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "FL_SET_CHANGELOG_PLATFORM",
                                       description: "The platform of the app (ios, appletvos, xros, mac)",
                                       default_value: "ios",
                                       verify_block: proc do |value|
                                         available = ['ios', 'appletvos', 'xros', 'mac']
                                         UI.user_error!("Invalid platform '#{value}', must be #{available.join(', ')}") unless available.include?(value)
                                       end)
        ]
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :appletvos, :xros, :mac].include?(platform)
      end

      def self.example_code
        [
          'set_changelog(changelog: "Changelog for all Languages")',
          'set_changelog(app_identifier: "com.krausefx.app", version: "1.0", changelog: "Changelog for all Languages")'
        ]
      end

      def self.category
        :app_store_connect
      end
    end
  end
end
