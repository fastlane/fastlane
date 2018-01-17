module Fastlane
  module Actions
    class OptOutUsageAction < Action
      def self.run(params)
        ENV['FASTLANE_OPT_OUT_USAGE'] = "YES"
        UI.message("Disabled upload of used actions")
      end

      def self.description
        "This will stop uploading the information which actions were run"
      end

      def self.details
        [
          "By default, fastlane will track what actions are being used",
          "No personal/sensitive information is recorded.",
          "Learn more at https://docs.fastlane.tools/#metrics",
          "Add `opt_out_usage` at the top of your Fastfile to disable metrics collection"
        ].join(' ')
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'opt_out_usage # add this to the top of your Fastfile'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
