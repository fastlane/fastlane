module Fastlane
  module Actions
    class UploadToTestflightAction < Action
      def self.run(values)
        require 'pilot'
        require 'pilot/options'

        changelog = Actions.lane_context[SharedValues::FL_CHANGELOG]
        values[:changelog] ||= changelog if changelog

        values[:ipa] ||= Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]
        values[:ipa] = File.expand_path(values[:ipa]) if values[:ipa]

        return values if Helper.test?

        Pilot::BuildManager.new.upload(values) # we already have the finished config
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload new binary to App Store Connect for TestFlight beta testing (via _pilot_)"
      end

      def self.details
        [
          "More details can be found on https://docs.fastlane.tools/actions/pilot/.",
          "This integration will only do the TestFlight upload."
        ].join("\n")
      end

      def self.available_options
        require "pilot"
        require "pilot/options"
        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options)
      end

      def self.example_code
        [
          'upload_to_testflight',
          'testflight # alias for "upload_to_testflight"',
          'pilot # alias for "upload_to_testflight"',
          'upload_to_testflight(skip_submission: true) # to only upload the build',
          'upload_to_testflight(
            username: "felix@krausefx.com",
            app_identifier: "com.krausefx.app",
            itc_provider: "abcde12345" # pass a specific value to the iTMSTransporter -itc_provider option
          )'
        ]
      end

      def self.category
        :beta
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
