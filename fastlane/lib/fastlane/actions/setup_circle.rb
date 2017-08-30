module Fastlane
  module Actions
    class SetupCircleAction < Action
      def self.run(params)
        # Stop if not executed by CI
        if !params[:force] && ENV["CIRCLECI"].to_s.length == 0
          UI.message "Currently not running on Circle system, skipping circle setup"
          return
        end

        # Create a temporary keychain
        password = "" # we don't need a password, as the keychain gets removed after each run anyway
        keychain_name = "fastlane_tmp_keychain"
        ENV["MATCH_KEYCHAIN_NAME"] = keychain_name
        ENV["MATCH_KEYCHAIN_PASSWORD"] = password

        UI.message "Creating temporary keychain: \"#{keychain_name}\"."
        Actions::CreateKeychainAction.run(
          name: keychain_name,
          default_keychain: true,
          unlock: true,
          timeout: 3600,
          lock_when_sleeps: true,
          password: password
        )

        circle_artifacts = ENV["CIRCLE_ARTIFACTS"]

        UI.message("Setting ouput directory for actions to Circle artifacts directory '#{circle_artifacts}'")
        ENV["SCAN_OUTPUT_DIRECTORY"] = circle_artifacts
        ENV["BACKUP_XCARCHIVE_DESTINATION"] = circle_artifacts
        ENV["GYM_OUTPUT_DIRECTORY"] = circle_artifacts
        ENV["GYM_BUILD_PATH"] = circle_artifacts

        # Enable readonly mode for match by default
        # we don't want to generate new identities and
        # profiles on Circle usually
        UI.message("Enabling readonly mode for Circle")
        ENV["MATCH_READONLY"] = true.to_s
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Setup match to work better with CircleCI"
      end

      def self.details
        [
          "- Switches match to `readonly` mode to not create new profiles/cert on CI",
          "",
          "This action helps with Circle integration, add this to the top of your Fastfile if you use Circle"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_SETUP_CIRCLE_FORCE",
                                       description: "Force setup, even if not executed by circle",
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
          'setup_circle'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
