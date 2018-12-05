module Fastlane
  module Actions
    class DebugAction < Action
      def self.run(params)
        puts("Lane Context".green)
        puts(Actions.lane_context)
      end

      def self.description
        "Print out an overview of the lane context values"
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'debug'
        ]
      end

      def self.category
        :misc
      end

      def self.author
        "KrauseFx"
      end
    end
  end
end
