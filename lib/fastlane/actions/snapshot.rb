module Fastlane
  module Actions
    module SharedValues
      SNAPSHOT_SCREENSHOTS_PATH = :SNAPSHOT_SCREENSHOTS_PATH
    end


    def self.snapshot(params)
      execute_action("snapshot") do
        require 'snapshot'

        clean = true
        clean = false if params.first == :noclean

        return clean if Helper.is_test?

        Snapshot::SnapshotConfig.shared_instance
        Snapshot::Runner.new.work(clean: clean)

        results_path = Snapshot::SnapshotConfig.shared_instance.screenshots_path

        self.shared_hash[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = File.expand_path(results_path) # absolute URL
      end
    end
  end
end