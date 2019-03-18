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
          )',
          'upload_to_testflight(
            beta_app_feedback_email: "email@email.com",
            beta_app_description: "This is a description of my app",
            demo_account_required: true,
            notify_external_testers: false,
            changelog: "This is my changelog of things that have changed in a log"
          )',
          'upload_to_testflight(
            beta_app_review_info: {
              contact_email: "email@email.com",
              contact_first_name: "Connect",
              contact_last_name: "API",
              contact_phone: "5558675309",
              demo_account_name: "demo@email.com",
              demo_account_password: "connectapi",
              notes: "this is review note for the reviewer <3 thank you for reviewing"
            },
            localized_app_info: {
              "default": {
                feedback_email: "default@email.com",
                marketing_url: "https://example.com/marketing-defafult",
                privacy_policy_url: "https://example.com/privacy-defafult",
                description: "Default description",
              },
              "en-GB": {
                feedback_email: "en-gb@email.com",
                marketing_url: "https://example.com/marketing-en-gb",
                privacy_policy_url: "https://example.com/privacy-en-gb",
                description: "en-gb description",
              }
            },
            localized_build_info: {
              "default": {
                whats_new: "Default changelog",
              },
              "en-GB": {
                whats_new: "en-gb changelog",
              }
            }
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
