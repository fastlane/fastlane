module Fastlane
  module Actions
    class AppstoreAction < Action
      def self.run(params)
        Actions::DeliverAction.run(params)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the deliver action"
      end

      def self.available_options
        require "deliver"
        require "deliver/options"
        FastlaneCore::CommanderGenerator.new.generate(Deliver::Options.available_options)
      end

      def self.output
        []
      end

      def self.author
        'KrauseFx'
      end

      def self.is_supported?(platform)
        Actions::DeliverAction.is_supported?(platform)
      end

      def self.category
        Actions::DeliverAction.category
      end

      def self.example_code
        Actions::DeliverAction.example_code
      end
    end
  end
end
