module Fastlane
  module Actions
    class SetupCircleCiAction < Action
      def self.run(params)
        unless should_run?(params)
          UI.message("Not running on CI, skipping `setup_circle_ci`")
          return
        end

        setup_keychain
        setup_output_paths(params)
      end

      def self.setup_output_paths(params)
        unless ENV["FL_OUTPUT_DIR"]
          UI.message("Skipping Log Path setup as FL_OUTPUT_DIR is unset")
          return
        end

        root = Pathname.new(ENV["FL_OUTPUT_DIR"])
        ENV["SCAN_OUTPUT_DIRECTORY"] = (root + "scan").to_s
        ENV["GYM_OUTPUT_DIRECTORY"] = (root + "gym").to_s
        ENV["FL_BUILDLOG_PATH"] = (root + "buildlogs").to_s
        ENV["SCAN_INCLUDE_SIMULATOR_LOGS"] = true.to_s
      end

      def self.setup_keychain
        unless ENV["MATCH_KEYCHAIN_NAME"].nil?
          UI.message("Skipping Keychain setup as a keychain was already specified")
          return
        end

        keychain_name = "fastlane_tmp_keychain"
        ENV["MATCH_KEYCHAIN_NAME"] = keychain_name
        ENV["MATCH_KEYCHAIN_PASSWORD"] = ""

        UI.message("Creating temporary keychain: \"#{keychain_name}\".")
        Actions::CreateKeychainAction.run(
          name: keychain_name,
          default_keychain: true,
          unlock: true,
          timeout: 3600,
          lock_when_sleeps: true,
          password: ""
        )

        UI.message("Enabling match readonly mode.")
        ENV["MATCH_READONLY"] = true.to_s
      end

      def self.should_run?(params)
        Helper.is_ci? || params[:force]
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Setup the keychain and match to work with CircleCI"
      end

      def self.details
        [
          "- Creates a new temporary keychain for use with match",
          "- Switches match to `readonly` mode to not create new profiles/cert on CI",
          "- Sets up log and test result paths to be easily collectible",
          "",
          "This action helps with CircleCI integration, add this to the top of your Fastfile if you use CircleCI"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_SETUP_CIRCLECI_FORCE",
                                       description: "Force setup, even if not executed by CircleCI",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.authors
        ["dantoml"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'setup_circle_ci'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
