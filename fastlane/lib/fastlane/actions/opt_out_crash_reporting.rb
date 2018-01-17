module Fastlane
  module Actions
    class OptOutCrashReportingAction < Action
      def self.run(params)
        ENV['FASTLANE_OPT_OUT_CRASH_REPORTING'] = "YES"
        UI.message("Disabled crash reporting")
      end

      def self.description
        "This will prevent reports from being uploaded when _fastlane_ crashes"
      end

      def self.details
        [
          "By default, fastlane will send a report when it crashes",
          "The stack trace is sanitized so no personal information is sent.",
          "Learn more at https://docs.fastlane.tools/actions/opt_out_crash_reporting/",
          "Add `opt_out_crash_reporting` at the top of your Fastfile to disable crash reporting"
        ].join(' ')
      end

      def self.authors
        ['mpirri', 'ohayon']
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'opt_out_crash_reporting # add this to the top of your Fastfile'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
