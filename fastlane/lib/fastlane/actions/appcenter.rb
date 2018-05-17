module Fastlane
  module Actions
    class AppcenterAction < Action
      def self.run(params)
        puts "This is fine!"
      end

      def self.description
        "Upload a new build to Appcenter"
      end

      def self.available_options
        platform = Actions.lane_context[Actions::SharedValues::PLATFORM_NAME]

        if platform == :ios || platform.nil?
          ipa_path_default = Dir["*.ipa"].sort_by { |x| File.mtime(x) }.last
        end

        if platform == :android
          apk_path_default = Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "app-release.apk")].last
        end

        [
          # iOS Specific
          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       env_name: "CRASHLYTICS_IPA_PATH",
                                       description: "Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || ipa_path_default,
                                       default_value_dynamic: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end),
          # Android Specific
          FastlaneCore::ConfigItem.new(key: :apk_path,
                                       env_name: "CRASHLYTICS_APK_PATH",
                                       description: "Path to your APK file",
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] || apk_path_default,
                                       default_value_dynamic: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find apk file at path '#{value}'") unless File.exist?(value)
                                       end),
          # General
          FastlaneCore::ConfigItem.new(key: :crashlytics_path,
                                       env_name: "CRASHLYTICS_FRAMEWORK_PATH",
                                       description: "Path to the submit binary in the Crashlytics bundle (iOS) or `crashlytics-devtools.jar` file (Android)",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find crashlytics at path '#{File.expand_path(value)}'`") unless File.exist?(File.expand_path(value))
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "CRASHLYTICS_API_TOKEN",
                                       description: "Crashlytics API Key",
                                       sensitive: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No API token for Crashlytics given, pass using `api_token: 'token'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :build_secret,
                                       env_name: "CRASHLYTICS_BUILD_SECRET",
                                       description: "Crashlytics Build Secret",
                                       sensitive: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No build secret for Crashlytics given, pass using `build_secret: 'secret'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :notes_path,
                                       env_name: "CRASHLYTICS_NOTES_PATH",
                                       description: "Path to the release notes",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Path '#{value}' not found") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :notes,
                                       env_name: "CRASHLYTICS_NOTES",
                                       description: "The release notes as string - uses :notes_path under the hood",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :groups,
                                       env_name: "CRASHLYTICS_GROUPS",
                                       description: "The groups used for distribution, separated by commas",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :emails,
                                       env_name: "CRASHLYTICS_EMAILS",
                                       description: "Pass email addresses of testers, separated by commas",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :notifications,
                                       env_name: "CRASHLYTICS_NOTIFICATIONS",
                                       description: "Crashlytics notification option (true/false)",
                                       default_value: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :debug,
                                       env_name: "CRASHLYTICS_DEBUG",
                                       description: "Crashlytics debug option (true/false)",
                                       default_value: false,
                                       is_string: false)

        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac, :android].include?(platform)
      end

      def self.author
        ["RishabhTayal"]
      end

      def self.details
        [
          "Additionally, you can specify `notes`, `emails`, `groups` and `notifications`.",
          "Distributing to Groups: When using the `groups` parameter, it's important to use the group **alias** names for each group you'd like to distribute to. A group's alias can be found in the web UI. If you're viewing the Beta page, you can open the groups dialog by clicking the 'Manage Groups' button."
        ].join("\n")
      end

      def self.example_code
        [
          'appcenter'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end
