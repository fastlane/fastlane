module Fastlane
  module Actions
    class PilotAction < Action
      def self.run(values)
        require 'pilot'
        require 'pilot/options'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('pilot') unless Helper.is_test?

          values[:ipa] ||= Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]

          return if Helper.test?

          Pilot::BuildManager.new.upload(values) # we already have the finished config
        ensure
          FastlaneCore::UpdateChecker.show_update_status('pilot', Pilot::VERSION)
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload a new binary to iTunes Connect for TestFlight beta testing"
      end

      def self.details
        [
          "More details can be found on https://github.com/fastlane/pilot",
          "This integration will only do the TestFlight upload"
        ].join("\n")
      end

      def self.available_options
        require "pilot"
        require "pilot/options"
        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options)
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
