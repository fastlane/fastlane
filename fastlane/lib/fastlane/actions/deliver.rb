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
          config[:screenshots_path] ||= Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] # use snapshot's screenshots
          config[:ipa] ||= Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]

          return config if Helper.test?
          Deliver::Runner.new(config).run
        ensure
          FastlaneCore::UpdateChecker.show_update_status('deliver', Deliver::VERSION)
        end
      end

      def self.description
        "Uses deliver to upload new app metadata and builds to iTunes Connect"
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
    end
  end
end
