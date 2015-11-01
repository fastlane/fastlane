module Fastlane
  module Actions
    class CrashlyticsAction < Action
      def self.run(params)
        params[:groups] = params[:groups].join(",") if params[:groups].kind_of?(Array)
        params[:emails] = params[:emails].join(",") if params[:emails].kind_of?(Array)

        params.values # to validate all inputs before looking for the ipa/apk

        if params[:notes]
          require 'tempfile'
          # We need to store it in a file, because the crashlytics CLI (iOS) says so
          Helper.log.error "Overwriting :notes_path, because you specified :notes" if params[:notes_path]

          changelog = Tempfile.new('changelog')
          changelog.write(params[:notes])
          changelog.close

          params[:notes_path] = changelog.path # we can only set it *after* writing the file there as it gets validated
        end

        if params[:ipa_path]
          command = Helper::CrashlyticsHelper.generate_ios_command(params)
        elsif params[:apk_path]
          command = Helper::CrashlyticsHelper.generate_android_command(params)
        else
          raise "You have to either pass an ipa or an apk file to the Crashlytics action".red
        end

        Helper.log.info 'Uploading the IPA to Crashlytics Beta. Time for some ☕️.'.green
        Helper.log.debug command.join(" ") if $verbose
        Actions.sh command.join(" ")

        return command if Helper.test?

        Helper.log.info 'Build successfully uploaded to Crashlytics Beta 🌷'.green
      end

      def self.description
        "Upload a new build to Crashlytics Beta"
      end

      def self.available_options
        [
          # iOS Specific
          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       env_name: "CRASHLYTICS_IPA_PATH",
                                       description: "Path to your IPA file. Optional if you use the `gym` or `xcodebuild` action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || Dir["*.ipa"].last,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Couldn't find ipa file at path '#{value}'".red unless File.exist?(value)
                                       end),
          # Android Specific
          FastlaneCore::ConfigItem.new(key: :apk_path,
                                       env_name: "CRASHLYTICS_APK_PATH",
                                       description: "Path to your APK file",
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] || Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "app-Release.apk")].last,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Couldn't find apk file at path '#{value}'".red unless File.exist?(value)
                                       end),

          # General
          FastlaneCore::ConfigItem.new(key: :crashlytics_path,
                                       env_name: "CRASHLYTICS_FRAMEWORK_PATH",
                                       description: "Path to the submit binary in the Crashlytics bundle (iOS) or `crashlytics-devtools.jar` file (Android)",
                                       default_value: Dir["./Pods/Crashlytics/Crashlytics.framework"].last,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Couldn't find crashlytics at path '#{File.expand_path(value)}'`".red unless File.exist?(File.expand_path(value))
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "CRASHLYTICS_API_TOKEN",
                                       description: "Crashlytics Beta API Token",
                                       verify_block: proc do |value|
                                         raise "No API token for Crashlytics given, pass using `api_token: 'token'`".red unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :build_secret,
                                       env_name: "CRASHLYTICS_BUILD_SECRET",
                                       description: "Crashlytics Build Secret",
                                       verify_block: proc do |value|
                                         raise "No build secret for Crashlytics given, pass using `build_secret: 'secret'`".red unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :notes_path,
                                       env_name: "CRASHLYTICS_NOTES_PATH",
                                       description: "Path to the release notes",
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Path '#{value}' not found".red unless File.exist?(value)
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
                                       is_string: false)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac, :android].include?(platform)
      end

      def self.author
        ["KrauseFx", "pedrogimenez"]
      end
    end
  end
end
