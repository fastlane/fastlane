module Fastlane
  module Actions
    class TestflightAction < Action
      def self.run(params)
        Actions::PilotAction.run(params)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the pilot action"
      end

      def self.available_options
        require "pilot"
        require "pilot/options"
        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options)
      end

      def self.output
        []
      end

      def self.author
        'KrauseFx'
      end

      def self.example_code
        Actions::PilotAction.example_code
      end

      def self.category
        Actions::PilotAction.category
      end

      def self.is_supported?(platform)
        Actions::PilotAction.is_supported?(platform)
      end
    end
  end
end
