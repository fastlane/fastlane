module Fastlane
  module Actions
    class SetupTravisAction < Action
      def self.run(params)
        # Stop if not executed by CI
        if !Helper.is_ci? && !params[:force]
          UI.message("Currently not running on CI system, skipping travis setup")
          return
        end

        # Create a temporary keychain
        password = "" # we don't need a password, as the keychain gets removed after each run anyway
        keychain_name = "fastlane_tmp_keychain"
        ENV["MATCH_KEYCHAIN_NAME"] = keychain_name
        ENV["MATCH_KEYCHAIN_PASSWORD"] = password

        UI.message("Creating temporary keychain: \"#{keychain_name}\".")
        Actions::CreateKeychainAction.run(
          name: keychain_name,
          default_keychain: true,
          unlock: true,
          timeout: 3600,
          lock_when_sleeps: true,
          password: password
        )

        # Enable readonly mode for match by default
        # we don't want to generate new identities and
        # profiles on Travis usually
        UI.message("Enabling readonly mode for Travis")
        ENV["MATCH_READONLY"] = true.to_s
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Setup the keychain and match to work with Travis CI"
      end

      def self.details
        [
          "- Creates a new temporary keychain for use with match",
          "- Switches match to `readonly` mode to not create new profiles/cert on CI",
          "",
          "This action helps with Travis integration, add this to the top of your Fastfile if you use Travis"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_SETUP_TRAVIS_FORCE",
                                       description: "Force setup, even if not executed by travis",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'setup_travis'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
