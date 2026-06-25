module Fastlane
  module Actions
    class UploadToTestflightAction < Action
      def self.run(values)
        require 'pilot'
        require 'pilot/options'

        distribute_only = values[:distribute_only]

        changelog = Actions.lane_context[SharedValues::FL_CHANGELOG]
        values[:changelog] ||= changelog if changelog

        unless distribute_only
          values[:ipa] ||= Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]
          values[:ipa] = File.expand_path(values[:ipa]) if values[:ipa]
          values[:pkg] ||= Actions.lane_context[SharedValues::PKG_OUTPUT_PATH]
          values[:pkg] = File.expand_path(values[:pkg]) if values[:pkg]
        end

        # Only set :api_key from SharedValues if :api_key_path isn't set (conflicting options)
        unless values[:api_key_path]
          values[:api_key] ||= Actions.lane_context[SharedValues::APP_STORE_CONNECT_API_KEY]
        end

        return values if Helper.test?

        if distribute_only
          build_manager = Pilot::BuildManager.new
          build_manager.start(values, should_login: true)

          build_manager.wait_for_build_processing_to_be_complete(false) unless values[:skip_waiting_for_build_processing]
          build_manager.distribute(values) # we already have the finished config
        else
          Pilot::BuildManager.new.upload(values) # we already have the finished config
        end
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
                marketing_url: "https://example.com/marketing-default",
                privacy_policy_url: "https://example.com/privacy-default",
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
        [:ios, :mac, :tvos].include?(platform)
      end
    end
  end
end
