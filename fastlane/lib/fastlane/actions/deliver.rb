module Fastlane
  module Actions
    module SharedValues
    end

    class DeliverAction < Action
      def self.run(config)
        require 'deliver'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('deliver') unless Helper.is_test?

          config.load_configuration_file("Deliverfile")
          config[:screenshots_path] = Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] if Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH]
          config[:ipa] = Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] if Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]

          return config if Helper.test?
          Deliver::Runner.new(config).run
        ensure
          FastlaneCore::UpdateChecker.show_update_status('deliver', Deliver::VERSION)
        end
      end

      def self.description
        "Uses deliver to upload new app metadata and builds to iTunes Connect"
      end

      def self.details
        [
          "Using _deliver_ after _gym_ and _snapshot_ will automatically upload the",
          "latest ipa and screenshots with no other configuration",
          "",
          "If you don't want a PDF report for App Store builds, use the `:force` option.",
          "This is useful when running _fastlane_ on your Continuous Integration server: `deliver(force: true)`",
          "If your account is on multiple teams and you need to tell the `iTMSTransporter`",
          "which 'provider' to use, you can set the `itc_provider` option to pass this info."
        ].join("\n")
      end

      def self.available_options
        require "deliver"
        require "deliver/options"
        FastlaneCore::CommanderGenerator.new.generate(Deliver::Options.available_options)
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'deliver(
            force: true, # Set to true to skip PDF verification
            itc_provider: "abcde12345" # pass a specific value to the iTMSTransporter -itc_provider option
          )'
        ]
      end

      def self.category
        :production
      end
    end
  end
end
