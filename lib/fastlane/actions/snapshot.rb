module Fastlane
  module Actions
    module SharedValues
      SNAPSHOT_SCREENSHOTS_PATH = :SNAPSHOT_SCREENSHOTS_PATH
    end

    class SnapshotAction
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
    end
  end
end
