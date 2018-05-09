module Fastlane
  module Actions
    class SetChangelogAction < Action
      def self.run(params)
        require 'spaceship'

        UI.message("Login to iTunes Connect (#{params[:username]})")
        Spaceship::Tunes.login(params[:username])
        Spaceship::Tunes.select_team
        UI.message("Login successful")

        app = Spaceship::Application.find(params[:app_identifier]) || Spaceship::Application.find(params[:app_identifier], mac: true)
        UI.user_error!("Couldn't find app with identifier #{params[:app_identifier]}") if app.nil?

        version_number = params[:version]
        platform = params[:platform]
        unless version_number
          # Automatically fetch the latest version
          UI.message("Fetching the latest version for this app")
          if app.edit_version(platform: platform) && app.edit_version(platform: platform).version
            version_number = app.edit_version(platform: platform).version
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

        if (v = app.edit_version(platform: platform))
          if v.version != version_number
            # Version is already there, make sure it matches the one we want to create
            UI.message("Changing existing version number from '#{v.version}' to '#{version_number}'")
            v.version = version_number
            v.save!
          else
            UI.message("Updating changelog for existing version #{v.version}")
          end
        else
          UI.message("Creating the new version: #{version_number}")
          app.create_version!(version_number)
          app = Spaceship::Application.find(params[:app_identifier]) # Replace with .reload method once available
          v = app.edit_version(platform: platform)
        end

        v.release_notes.languages.each do |lang|
          v.release_notes[lang] = changelog
        end

        UI.message("Found and updated changelog for the following languages: #{v.release_notes.languages.join(', ')}")
        UI.message("Uploading changes to iTunes Connect...")
        v.save!

        UI.success("👼  Successfully pushed the new changelog to #{v.url}")
      end

      def self.default_changelog_path
        File.join(FastlaneCore::FastlaneFolder.path.to_s, 'changelog.txt')
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set the changelog for all languages on iTunes Connect"
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
                                     default_value: user,
                                     default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_SET_CHANGELOG_VERSION",
                                       description: "The version number to create/update",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :changelog,
                                       env_name: "FL_SET_CHANGELOG_CHANGELOG",
                                       description: "Changelog text that should be uploaded to iTunes Connect",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-k",
                                       env_name: "FL_SET_CHANGELOG_TEAM_ID",
                                       description: "The ID of your iTunes Connect team if you're in multiple teams",
                                       optional: true,
                                       is_string: false, # as we also allow integers, which we convert to strings anyway
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-e",
                                       env_name: "FL_SET_CHANGELOG_TEAM_NAME",
                                       description: "The name of your iTunes Connect team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "FL_SET_CHANGELOG_PLATFORM",
                                       description: "The platform of the app (ios, appletvos, mac)",
                                       default_value: "ios",
                                       verify_block: proc do |value|
                                         available = ['ios', 'appletvos', 'mac']
                                         UI.user_error!("Invalid platform '#{value}', must be #{available.join(', ')}") unless available.include?(value)
                                       end)
        ]
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :appletvos, :mac].include?(platform)
      end

      def self.example_code
        [
          'set_changelog(changelog: "Changelog for all Languages")',
          'set_changelog(app_identifier: "com.krausefx.app", version: "1.0", changelog: "Changelog for all Languages")'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end
