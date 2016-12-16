module Fastlane
  module Actions
    module SharedValues
      SNAPSHOT_SCREENSHOTS_PATH = :SNAPSHOT_SCREENSHOTS_PATH
    end

    class SnapshotAction < Action
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
        "Generate new localised screenshots on multiple devices"
      end

      def self.available_options
        return [] unless Helper.mac?
        require 'snapshot'
        Snapshot::Options.available_options
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'snapshot',
          'snapshot(
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
