module Fastlane
  module Actions
    module SharedValues
      SNAPSHOT_SCREENSHOTS_PATH = :SNAPSHOT_SCREENSHOTS_PATH
    end

    class CaptureIosScreenshotsAction < Action
      def self.run(params)
        return nil unless Helper.mac?
        require 'snapshot'

        Snapshot.config = params
        Snapshot::DependencyChecker.check_simulators
        Snapshot::Runner.new.work

        Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = File.expand_path(params[:output_directory]) # absolute URL

        true
      end

      def self.description
        "Generate new localized screenshots on multiple devices (via _snapshot_)"
      end

      def self.available_options
        return [] unless Helper.mac?
        require 'snapshot'
        Snapshot::Options.available_options
      end

      def self.output
        [
          ['SNAPSHOT_SCREENSHOTS_PATH', 'The path to the screenshots']
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'capture_ios_screenshots',
          'snapshot # alias for "capture_ios_screenshots"',
          'capture_ios_screenshots(
            skip_open_summary: true,
            clean: true
          )'
        ]
      end

      def self.category
        :screenshots
      end
    end
  end
end
