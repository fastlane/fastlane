module Fastlane
  module Actions
    class OptOutCrashReportingAction < Action
      def self.run(params)
        UI.message("fastlane doesn't have crash reporting any more, feel free to remove `opt_out_crash_reporting` from your Fastfile")
      end

      def self.description
        "This will prevent reports from being uploaded when _fastlane_ crashes"
      end

      def self.details
        [
          "fastlane doesn't have crash reporting any more, feel free to remove `opt_out_crash_reporting` from your Fastfile"
        ].join(' ')
      end

      def self.authors
        ['mpirri', 'ohayon']
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        []
      end

      def self.category
        :deprecated
      end
    end
  end
end
