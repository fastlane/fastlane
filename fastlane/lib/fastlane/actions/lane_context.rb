module Fastlane
  module Actions
    class LaneContextAction < Action
      def self.run(params)
        Actions.lane_context
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "An alias to `Actions.lane_context`"
      end

      def self.available_options
        []
      end

      def self.output
        []
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      # We don't want to show this as step
      def self.step_text
        nil
      end

      def self.example_code
        []
      end

      def self.category
        :misc
      end
    end
  end
end
