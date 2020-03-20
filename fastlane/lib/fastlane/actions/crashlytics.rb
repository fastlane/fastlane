module Fastlane
  module Actions
    class CrashlyticsAction < Action
      def self.run(params)
        params[:groups] = params[:groups].join(",") if params[:groups].kind_of?(Array)
        params[:emails] = params[:emails].join(",") if params[:emails].kind_of?(Array)

        params.values # to validate all inputs before looking for the ipa/apk
        tempfiles = []

        # We need to store notes in a file, because the crashlytics CLI (iOS) says so
        if params[:notes]
          UI.error("Overwriting :notes_path, because you specified :notes") if params[:notes_path]

          changelog = Helper::CrashlyticsHelper.write_to_tempfile(params[:notes], 'changelog')
          tempfiles << changelog
          params[:notes_path] = changelog.path
        elsif Actions.lane_context[SharedValues::FL_CHANGELOG] && !params[:notes_path]
          UI.message("Sending FL_CHANGELOG as release notes to Beta by Crashlytics")

          changelog = Helper::CrashlyticsHelper.write_to_tempfile(
            Actions.lane_context[SharedValues::FL_CHANGELOG], 'changelog'
          )
          tempfiles << changelog
          params[:notes_path] = changelog.path
        end

        if params[:ipa_path]
          command = Helper::CrashlyticsHelper.generate_ios_command(params)
        elsif params[:apk_path]
          android_manifest = Helper::CrashlyticsHelper.generate_android_manifest_tempfile
          tempfiles << android_manifest
          command = Helper::CrashlyticsHelper.generate_android_command(params, android_manifest.path)
        else
          UI.user_error!("You have to either pass an ipa or an apk file to the Crashlytics action")
        end

        UI.success('Uploading the build to Crashlytics Beta. Time for some ☕️.')

        sanitizer = proc do |message|
          message.gsub(params[:api_token], '[[API_TOKEN]]')
                 .gsub(params[:build_secret], '[[BUILD_SECRET]]')
        end

        UI.verbose(sanitizer.call(command.join(' '))) if FastlaneCore::Globals.verbose?

        error_callback = proc do |error|
          clean_error = sanitizer.call(error)
          UI.user_error!(clean_error)
        end

        result = Actions.sh_control_output(
          command.join(" "),
          print_command: false,
          print_command_output: false,
          error_callback: error_callback
        )

        tempfiles.each(&:unlink)
        return command if Helper.test?

        UI.verbose(sanitizer.call(result)) if FastlaneCore::Globals.verbose?

        UI.success('Build successfully uploaded to Crashlytics Beta 🌷')
        UI.success('Visit https://fabric.io/_/beta to add release notes and notify testers.')
      end

      def self.description
        "Refer to [Firebase App Distribution](https://appdistro.page.link/fastlane-repo)"
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
        ["KrauseFx", "pedrogimenez"]
      end

      def self.details
        [
          "Crashlytics Beta has been deprecated and replaced with Firebase App Distribution.",
          "Beta will continue working until May 4, 2020.",
          "Check out the [Firebase App Distribution docs](https://github.com/fastlane/fastlane-plugin-firebase_app_distribution) to get started.",
          "",
          "Additionally, you can specify `notes`, `emails`, `groups` and `notifications`.",
          "Distributing to Groups: When using the `groups` parameter, it's important to use the group **alias** names for each group you'd like to distribute to. A group's alias can be found in the web UI. If you're viewing the Beta page, you can open the groups dialog by clicking the 'Manage Groups' button.",
          "This action uses the `submit` binary provided by the Crashlytics framework. If the binary is not found in its usual path, you'll need to specify the path manually by using the `crashlytics_path` option."
        ].join("\n")
      end

      def self.example_code
        [
          'crashlytics',
          '# If you installed Crashlytics via CocoaPods
          crashlytics(
            crashlytics_path: "./Pods/Crashlytics/submit", # path to your Crashlytics submit binary.
            api_token: "...",
            build_secret: "...",
            ipa_path: "./app.ipa"
          )',
          '# If you installed Crashlytics via Carthage for iOS platform
          crashlytics(
            crashlytics_path: "./Carthage/Build/iOS/Crashlytics.framework/submit", # path to your Crashlytics submit binary.
            api_token: "...",
            build_secret: "...",
            ipa_path: "./app.ipa"
          )'
        ]
      end

      def self.category
        :deprecated
      end

      def self.deprecated_notes
        [
          "Crashlytics Beta has been deprecated and replaced with Firebase App Distribution.",
          "Beta will continue working until May 4, 2020.",
          "Check out the [Firebase App Distribution docs](https://github.com/fastlane/fastlane-plugin-firebase_app_distribution) to get started."
        ].join("\n")
      end
    end
  end
end
