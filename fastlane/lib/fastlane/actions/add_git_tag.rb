module Fastlane
  module Actions
    # Adds a git tag to the current commit
    class AddGitTagAction < Action
      def self.run(options)
        lane_name = Actions.lane_context[Actions::SharedValues::LANE_NAME].delete(' ') # no spaces allowed

        tag = options[:tag] || "#{options[:grouping]}/#{lane_name}/#{options[:prefix]}#{options[:build_number]}"

        UI.message "Adding git tag '#{tag}' 🎯."
        Actions.sh("git tag -am '#{tag} (fastlane)' '#{tag}'")
      end

      def self.description
        "This will add an annotated git tag to the current branch"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :tag,
                                       env_name: "FL_GIT_TAG_TAG",
                                       description: "Define your own tag text. This will replace all other parameters",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :grouping,
                                       env_name: "FL_GIT_TAG_GROUPING",
                                       description: "Is used to keep your tags organised under one 'folder'. Defaults to 'builds'",
                                       default_value: 'builds'),
          FastlaneCore::ConfigItem.new(key: :prefix,
                                       env_name: "FL_GIT_TAG_PREFIX",
                                       description: "Anything you want to put in front of the version number (e.g. 'v')",
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "FL_GIT_TAG_BUILD_NUMBER",
                                       description: "The build number. Defaults to the result of increment_build_number if you\'re using it",
                                       default_value: Actions.lane_context[Actions::SharedValues::BUILD_NUMBER],
                                       is_string: false)
        ]
      end

      def self.author
        "lmirosevic"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
