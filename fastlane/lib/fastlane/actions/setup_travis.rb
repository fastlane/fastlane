module Fastlane
  module Actions
    class SetupTravisAction < Action
      def self.run(params)
        other_action.setup_ci(provider: "travis", force: params[:force])
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Setup the keychain and match to work with Travis CI"
      end

      def self.details
        list = <<-LIST.markdown_list(true)
          Creates a new temporary keychain for use with match
          Switches match to `readonly` mode to not create new profiles/cert on CI
        LIST

        [
          list,
          "This action helps with Travis integration. Add this to the top of your Fastfile if you use Travis."
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
