# Workaround, since crashlytics.rb from shenzhen includes the code for commander.
def command(_param)
end

module Fastlane
  module Actions
    class CrashlyticsAction < Action
      
      def self.is_supported?(platform)
        [:ios, :mac].include?platform
      end

      def self.run(params)
        require 'shenzhen'
        require 'shenzhen/plugins/crashlytics'

        # can pass groups param either as an Array or a String
        case params[:groups]
        when NilClass
          groups = nil
        when Array
          groups = params[:groups].join(',')
        when String
          groups = params[:groups]
        end

        # Normalized notification to Crashlytics notification parameter requirement
        # 'YES' or 'NO' - String
        case params[:notifications]
          when String
            if params[:notifications] == 'YES' || params[:notifications] == 'NO'
              notifications = params[:notifications]
            else
              notifications = 'YES' if params[:notifications] == 'true'
              notifications = 'NO' if params[:notifications] == 'false'
            end
          when TrueClass
            notifications = 'YES'
          when FalseClass
            notifications = 'NO'
          else
            notifications = nil
        end

        Helper.log.info 'Uploading the IPA to Crashlytics. Go for a coffee ☕️.'.green

        if Helper.test?
          # Access all values, to do the verify
          return params[:crashlytics_path], params[:api_token], params[:build_secret], params[:ipa_path], params[:build_secret], params[:ipa_path], params[:notes_path], params[:emails], groups, notifications
        end

        client = Shenzhen::Plugins::Crashlytics::Client.new(params[:crashlytics_path], params[:api_token], params[:build_secret])

        response = client.upload_build(params[:ipa_path], file: params[:ipa_path], notes: params[:notes_path], emails: params[:emails], groups: groups, notifications: notifications)

        if response
          Helper.log.info 'Build successfully uploaded to Crashlytics'.green
        else
          Helper.log.fatal 'Error uploading to Crashlytics.'
          raise 'Error when trying to upload ipa to Crashlytics'.red
        end
      end

      def self.description
        "Upload a new build to Crashlytics Beta"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :crashlytics_path,
                                       env_name: "CRASHLYTICS_FRAMEWORK_PATH",
                                       description: "Path to the submit binary in the Crashlytics bundle",
                                       verify_block: Proc.new do |value|
                                        raise "No Crashlytics path given or found, pass using `crashlytics_path: 'path'`".red unless File.exists?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "CRASHLYTICS_API_TOKEN",
                                       description: "Crashlytics Beta API Token",
                                       verify_block: Proc.new do |value|
                                          raise "No API token for Crashlytics given, pass using `api_token: 'token'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :build_secret,
                                       env_name: "CRASHLYTICS_BUILD_SECRET",
                                       description: "Crashlytics Build Secret",
                                       verify_block: Proc.new do |value|
                                        raise "No build secret for Crashlytics given, pass using `build_secret: 'secret'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       env_name: "CRASHLYTICS_IPA_PATH",
                                       description: "Path to your IPA file. Optional if you use the `ipa` or `xcodebuild` action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: Proc.new do |value|
                                        raise "Couldn't find ipa file at path '#{value}'".red unless File.exists?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :notes_path,
                                       env_name: "CRASHLYTICS_NOTES_PATH",
                                       description: "Path to the release notes",
                                       optional: true,
                                       verify_block: Proc.new do |value|
                                        raise "Path '#{value}' not found".red unless File.exists?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :groups,
                                       env_name: "CRASHLYTICS_GROUPS",
                                       description: "The groups used for distribution",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :emails,
                                       env_name: "CRASHLYTICS_EMAILS",
                                       description: "Pass email addresses, separated by commas",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :notifications,
                                       env_name: "CRASHLYTICS_NOTIFICATIONS",
                                       description: "Crashlytics notification option (true/false)",
                                       optional: true,
                                       is_string: false,
                                       verify_block: Proc.new do |value|
                                         raise "Crashlytics supported notifications options: TrueClass, FalseClass, 'true', 'false', 'YES', 'NO'".red unless (value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(String))
                                       end)
        ]
      end

      def self.author
        "pedrogimenez"
      end
    end
  end
end
