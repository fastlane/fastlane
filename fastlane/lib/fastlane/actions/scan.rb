module Fastlane
  module Actions
    class ScanAction < Action
      def self.run(values)
        require 'scan'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('scan') unless Helper.is_test?

          Scan::Manager.new.work(values)

          true
        ensure
          FastlaneCore::UpdateChecker.show_update_status('scan', Scan::VERSION)
        end
      end

      def self.description
        "Easily test your app using `scan`"
      end

      def self.details
        "More information: https://github.com/fastlane/scan"
      end

      def self.author
        "KrauseFx"
      end

      def self.available_options
        require 'scan'
        Scan::Options.available_options
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
