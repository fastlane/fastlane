module Fastlane
  module Actions
    def self.snapshot(params)
      need_gem!'snapshot'

      require 'snapshot'
      ENV['SNAPSHOT_SCREENSHOTS_PATH'] = self.snapshot_screenshots_folder
      Snapshot::SnapshotConfig.shared_instance
      Snapshot::Runner.new.work(clean: false)
    end

    def self.snapshot_screenshots_folder
      './screenshots'
    end
  end
end