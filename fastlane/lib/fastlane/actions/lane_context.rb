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
        "Access lane context values"
      end

      def self.details
        [
          "Access the fastlane lane context values",
          "More information about how the lane context works: https://docs.fastlane.tools/advanced/#lane-context"
        ].join("\n")
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
        [
          'lane_context[SharedValues::BUILD_NUMBER]',
          'lane_context[SharedValues::IPA_OUTPUT_PATH]'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
