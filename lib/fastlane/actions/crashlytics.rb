# TODO: Workaround, since crashlytics.rb from shenzhen includes the code for commander.
def command(_param)
end

module Fastlane
  module Actions
    class CrashlyticsAction < Action
      
      def self.is_supported?(platform)
        platform == :ios
      end

      def self.run(params)
        require 'shenzhen'
        require 'shenzhen/plugins/crashlytics'

        assert_params_given!(params)

        params = params.first

        crashlytics_path = params[:crashlytics_path] || ENV["CRASHLYTICS_FRAMEWORK_PATH"]
        api_token        = params[:api_token] || ENV["CRASHLYTICS_API_TOKEN"]
        build_secret     = params[:build_secret] || ENV["CRASHLYTICS_BUILD_SECRET"]
        ipa_path         = params[:ipa_path] || Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]
        notes_path       = params[:notes_path]
        emails           = params[:emails]
        notifications    = params[:notifications]

        # can pass groups param either as an Array or a String
        case params[:groups]
        when NilClass
          groups = nil
        when Array
          groups = params[:groups].join(',')
        when String
          groups = params[:groups]
        end

        assert_valid_params!(crashlytics_path, api_token, build_secret, ipa_path)

        Helper.log.info 'Uploading the IPA to Crashlytics. Go for a coffee ☕️.'.green

        return if Helper.test?

        client = Shenzhen::Plugins::Crashlytics::Client.new(crashlytics_path, api_token, build_secret)

        response = client.upload_build(ipa_path, file: ipa_path, notes: notes_path, emails: emails, groups: groups, notifications: notifications)

        if response
          Helper.log.info 'Build successfully uploaded to Crashlytics'.green
        else
          Helper.log.fatal 'Error uploading to Crashlytics.'
          raise 'Error when trying to upload ipa to Crashlytics'.red
        end
      end

      private

      def self.assert_params_given!(params)
        return unless params.empty?
        raise 'You have to pass Crashlytics parameters to the Crashlytics action, take a look at https://github.com/KrauseFx/fastlane#crashlytics'.red
      end

      def self.assert_valid_params!(crashlytics_path, api_token, build_secret, ipa_path)
        assert_valid_crashlytics_path!(crashlytics_path)
        assert_valid_api_token!(api_token)
        assert_valid_build_secret!(build_secret)
        assert_valid_ipa_path!(ipa_path)
      end

      def self.assert_valid_crashlytics_path!(crashlytics_path)
        return if crashlytics_path && File.exist?(crashlytics_path)
        raise "No Crashlytics path given or found, pass using `crashlytics_path: 'path'`".red
      end

      def self.assert_valid_api_token!(token)
        return unless token.nil? || token.empty?
        raise "No API token for Crashlytics given, pass using `api_token: 'token'`".red
      end

      def self.assert_valid_build_secret!(build_secret)
        return unless build_secret.nil? || build_secret.empty?
        raise "No build secret for Crashlytics given, pass using `build_secret: 'secret'`".red
      end

      def self.assert_valid_ipa_path!(ipa_path)
        return if ipa_path && File.exist?(ipa_path)
        raise "No IPA file given or found, pass using `ipa_path: 'path/app.ipa'`".red
      end

      def self.description
        "Upload a new build to Crashlytics Beta"
      end

      def self.available_options
        [
          ['crashlytics_path', 'Path to your Crashlytics bundle', 'CRASHLYTICS_FRAMEWORK_PATH'],
          ['api_token', 'Crashlytics Beta API Token', 'CRASHLYTICS_API_TOKEN'],
          ['build_secret', 'Crashlytics Build Secret', 'CRASHLYTICS_BUILD_SECRET'],
          ['ipa_path', 'Path to your IPA file. Optional if you use the `ipa` or `xcodebuild` action'],
          ['notes_path', 'Release Notes'],
          ['emails', 'Pass email address'],
          ['notifications', 'Crashlytics notification option']
        ]
      end

      def self.author
        "pedrogimenez"
      end

      private_class_method :assert_params_given!,
                           :assert_valid_params!,
                           :assert_valid_crashlytics_path!,
                           :assert_valid_api_token!,
                           :assert_valid_build_secret!,
                           :assert_valid_ipa_path!
    end
  end
end
