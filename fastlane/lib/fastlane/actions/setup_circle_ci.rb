require 'fastlane/ci'

module Fastlane
  module Actions
    class SetupCircleCiAction < Action
      def self.run(params)
        unless Ci.should_run?(force: params[:force])
          UI.message("Not running on CI, skipping `setup_circle_ci`")
          return
        end

        Ci.setup_keychain
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

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Setup the keychain and match to work with CircleCI"
      end

      def self.details
        list = <<-LIST.markdown_list(true)
          Creates a new temporary keychain for use with match
          Switches match to `readonly` mode to not create new profiles/cert on CI
          Sets up log and test result paths to be easily collectible
        LIST

        [
          list,
          "This action helps with CircleCI integration. Add this to the top of your Fastfile if you use CircleCI."
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
