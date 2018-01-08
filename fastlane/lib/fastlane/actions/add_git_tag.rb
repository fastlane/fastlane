module Fastlane
  module Actions
    # Adds a git tag to the current commit
    class AddGitTagAction < Action
      def self.run(options)
        # lane name in lane_context could be nil because you can just call $fastlane add_git_tag which has no context
        lane_name = Actions.lane_context[Actions::SharedValues::LANE_NAME].to_s.delete(' ') # no spaces allowed

        tag = options[:tag] || "#{options[:grouping]}/#{lane_name}/#{options[:prefix]}#{options[:build_number]}"
        message = options[:message] || "#{tag} (fastlane)"

        cmd = ['git tag']

        cmd << ["-am #{message.shellescape}"]
        cmd << '--force' if options[:force]
        cmd << '-s' if options[:sign]
        cmd << "'#{tag}'"
        cmd << options[:commit].to_s if options[:commit]

        UI.message("Adding git tag '#{tag}' 🎯.")
        Actions.sh(cmd.join(' '))
      end

      def self.description
        "This will add an annotated git tag to the current branch"
      end

      def self.details
        [
          "This will automatically tag your build with the following format: `<grouping>/<lane>/<prefix><build_number>`, where:",
          "- `grouping` is just to keep your tags organised under one 'folder', defaults to 'builds'",
          "- `lane` is the name of the current fastlane lane",
          "- `prefix` is anything you want to stick in front of the version number, e.g. 'v'",
          "- `build_number` is the build number, which defaults to the value emitted by the `increment_build_number` action",
          "",
          "For example for build 1234 in the 'appstore' lane it will tag the commit with `builds/appstore/1234`"
        ].join("\n")
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
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_GIT_TAG_MESSAGE",
                                       description: "The tag message. Defaults to the tag's name",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :commit,
                                       env_name: "FL_GIT_TAG_COMMIT",
                                       description: "The commit or object where the tag will be set. Defaults to the current HEAD",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_GIT_TAG_FORCE",
                                       description: "Force adding the tag",
                                       optional: true,
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :sign,
                                       env_name: "FL_GIT_TAG_SIGN",
                                       description: "Make a GPG-signed tag, using the default e-mail address's key",
                                       optional: true,
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.example_code
        [
          'add_git_tag # simple tag with default values',
          'add_git_tag(
            grouping: "fastlane-builds",
            prefix: "v",
            build_number: 123
          )',
          '# Alternatively, you can specify your own tag. Note that if you do specify a tag, all other arguments are ignored.
          add_git_tag(
            tag: "my_custom_tag"
          )'
        ]
      end

      def self.category
        :source_control
      end

      def self.authors
        ["lmirosevic", "maschall"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
