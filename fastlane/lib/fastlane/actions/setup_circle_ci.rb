module Fastlane
  module Actions
    class SetupCircleCiAction < Action
      def self.run(params)
        other_action.setup_ci(provider: "circleci", force: params[:force])
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
                                       type: Boolean,
                                       default_value: false)
        ]
      end

      def self.authors
        ["dantoml"]
      end

      def self.is_supported?(platform)
        true
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
