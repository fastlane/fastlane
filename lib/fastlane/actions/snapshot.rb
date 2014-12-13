module Fastlane
  module Actions
    def self.snapshot(params)
      execute_action("snapshot") do
        need_gem!'snapshot'

        require 'snapshot'
        ENV['SNAPSHOT_SCREENSHOTS_PATH'] = self.snapshot_screenshots_folder

        clean = true
        clean = false if params.first == :noclean

        Snapshot::SnapshotConfig.shared_instance
        Snapshot::Runner.new.work(clean: clean)
      end
    end

    def self.snapshot_screenshots_folder
      './screenshots'
    end
  end
end