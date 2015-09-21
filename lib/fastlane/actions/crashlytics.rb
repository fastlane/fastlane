module Fastlane
  module Actions
    class CrashlyticsAction < Action
      def self.run(params)
        Helper.log.info 'Uploading the IPA to Crashlytics Beta. Time for some ☕️.'.green

        params[:groups] = params[:groups].join(",") if params[:groups].kind_of?(Array)
        params[:emails] = params[:emails].join(",") if params[:emails].kind_of?(Array)

        command = []
        command << File.join(params[:crashlytics_path], 'submit')
        command << params[:api_token]
        command << params[:build_secret]
        command << "-ipaPath '#{params[:ipa_path]}'"
        command << "-emails '#{params[:emails]}'" if params[:emails]
        command << "-notesPath '#{params[:notes_path]}'" if params[:notes_path]
        command << "-groupAliases '#{params[:groups]}'" if params[:groups]
        command << "-notifications #{(params[:notifications] ? 'YES' : 'NO')}"
        
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
          FastlaneCore::ConfigItem.new(key: :crashlytics_path,
                                       env_name: "CRASHLYTICS_FRAMEWORK_PATH",
                                       description: "Path to the submit binary in the Crashlytics bundle",
                                       default_value: Dir["./Pods/Crashlytics/Crashlytics.framework"].last,
                                       verify_block: proc do |value|
                                         raise "No Crashlytics path given or found, pass using `crashlytics_path: 'path'`".red unless File.exist?(value)
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
          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       env_name: "CRASHLYTICS_IPA_PATH",
                                       description: "Path to your IPA file. Optional if you use the `ipa` or `xcodebuild` action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: proc do |value|
                                         raise "Couldn't find ipa file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :notes_path,
                                       env_name: "CRASHLYTICS_NOTES_PATH",
                                       description: "Path to the release notes",
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Path '#{value}' not found".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :groups,
                                       env_name: "CRASHLYTICS_GROUPS",
                                       description: "The groups used for distribution",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :emails,
                                       env_name: "CRASHLYTICS_EMAILS",
                                       description: "Pass email addresses, separated by commas",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :notifications,
                                       env_name: "CRASHLYTICS_NOTIFICATIONS",
                                       description: "Crashlytics notification option (true/false)",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "Crashlytics supported notifications options: TrueClass, FalseClass, 'true', 'false', 'YES', 'NO'".red unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass) || value.kind_of?(String)
                                       end)
        ]
      end

      def self.author
        "pedrogimenez"
      end
    end
  end
end
