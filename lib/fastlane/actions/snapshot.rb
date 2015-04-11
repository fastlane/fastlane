module Fastlane
  module Actions
    module SharedValues
      SNAPSHOT_SCREENSHOTS_PATH = :SNAPSHOT_SCREENSHOTS_PATH
    end

    class SnapshotAction < Action
      def self.run(params)
        clean = true
        clean = false if params.include?(:noclean)
        $verbose = true if params.include?(:verbose)

        if Helper.test?
          Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = Dir.pwd
          return clean
        end

        require 'snapshot'

        Dir.chdir(FastlaneFolder.path) do
          Snapshot::SnapshotConfig.shared_instance
          Snapshot::Runner.new.work(clean: clean)

          results_path = Snapshot::SnapshotConfig.shared_instance.screenshots_path

          Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = File.expand_path(results_path) # absolute URL
        end
      end

      def self.description
        "Generate new localised screenshots on multiple devices"
      end

      def self.available_options
        [
          ['noclean', 'Skips the clean process when building the app'],
          ['verbose', 'Print out the UI Automation output']
        ]
      end
    end
  end
end
