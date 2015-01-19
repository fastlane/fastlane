module Fastlane
  module Actions
    module SharedValues
      SNAPSHOT_SCREENSHOTS_PATH = :SNAPSHOT_SCREENSHOTS_PATH
    end

    class SnapshotAction
      def self.run(params)
        require 'snapshot'

        clean = true
        clean = false if params.first == :noclean

        if Helper.is_test?
          Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = Dir.pwd
          return clean 
        end

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