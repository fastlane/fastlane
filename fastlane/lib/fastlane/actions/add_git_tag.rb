module Fastlane
  module Actions
    # Adds a git tag to the current commit
    class AddGitTagAction < Action
      def self.run(options)
        # lane name in lane_context could be nil because you can just call $fastlane add_git_tag which has no context
        lane_name = Actions.lane_context[Actions::SharedValues::LANE_NAME].to_s.delete(' ') # no spaces allowed

        if options[:tag]
          tag = options[:tag]
        elsif options[:build_number]
          tag_components = [options[:grouping]]
          tag_components << lane_name if options[:includes_lane]
          tag_components << "#{options[:prefix]}#{options[:build_number]}#{options[:postfix]}"
          tag = tag_components.join('/')
        else
          UI.user_error!("No value found for 'tag' or 'build_number'. At least one of them must be provided. Note that if you do specify a tag, all other arguments are ignored.")
        end
        message = options[:message] || "#{tag} (fastlane)"

        cmd = ['git tag']

        cmd << ["-am #{message.shellescape}"]
        cmd << '--force' if options[:force]
        cmd << '-s' if options[:sign]
        cmd << tag.shellescape
        cmd << options[:commit].to_s if options[:commit]

        UI.message("Adding git tag '#{tag}' 🎯.")
        Actions.sh(cmd.join(' '))
      end

      def self.description
        "This will add an annotated git tag to the current branch"
      end

      def self.details
        list = <<-LIST.markdown_list
          `grouping` is just to keep your tags organised under one 'folder', defaults to 'builds'
          `lane` is the name of the current fastlane lane, if chosen to be included via 'includes_lane' option, which defaults to 'true'
          `prefix` is anything you want to stick in front of the version number, e.g. 'v'
          `postfix` is anything you want to stick at the end of the version number, e.g. '-RC1'
          `build_number` is the build number, which defaults to the value emitted by the `increment_build_number` action
        LIST

        [
          "This will automatically tag your build with the following format: `<grouping>/<lane>/<prefix><build_number><postfix>`, where:".markdown_preserve_newlines,
          list,
          "For example, for build 1234 in the 'appstore' lane, it will tag the commit with `builds/appstore/1234`."
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
                                       description: "Is used to keep your tags organised under one 'folder'",
                                       default_value: 'builds'),
          FastlaneCore::ConfigItem.new(key: :includes_lane,
                                       env_name: "FL_GIT_TAG_INCLUDES_LANE",
                                       description: "Whether the current lane should be included in the tag and message composition, e.g. '<grouping>/<lane>/<prefix><build_number><postfix>'",
                                       type: Boolean,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :prefix,
                                       env_name: "FL_GIT_TAG_PREFIX",
                                       description: "Anything you want to put in front of the version number (e.g. 'v')",
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :postfix,
                                       env_name: "FL_GIT_TAG_POSTFIX",
                                       description: "Anything you want to put at the end of the version number (e.g. '-RC1')",
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "FL_GIT_TAG_BUILD_NUMBER",
                                       description: "The build number. Defaults to the result of increment_build_number if you\'re using it",
                                       default_value: Actions.lane_context[Actions::SharedValues::BUILD_NUMBER],
                                       default_value_dynamic: true,
                                       skip_type_validation: true, # skipping validation because we both allow integer and string
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_GIT_TAG_MESSAGE",
                                       description: "The tag message. Defaults to the tag's name",
                                       default_value_dynamic: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :commit,
                                       env_name: "FL_GIT_TAG_COMMIT",
                                       description: "The commit or object where the tag will be set. Defaults to the current HEAD",
                                       default_value_dynamic: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_GIT_TAG_FORCE",
                                       description: "Force adding the tag",
                                       optional: true,
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :sign,
                                       env_name: "FL_GIT_TAG_SIGN",
                                       description: "Make a GPG-signed tag, using the default e-mail address's key",
                                       optional: true,
                                       type: Boolean,
                                       default_value: false)
        ]
      end

      def self.example_code
        [
          'add_git_tag # simple tag with default values',
          'add_git_tag(
            grouping: "fastlane-builds",
            includes_lane: true,
            prefix: "v",
            postfix: "-RC1",
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
