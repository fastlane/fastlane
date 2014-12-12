module Fastlane
  module Actions
    def self.snapshot(params)
      ENV['SNAPSHOT_SCREENSHOTS_PATH'] = self.snapshot_screenshots_folder
      sh "snapshot"
    end

    def self.snapshot_screenshots_folder
      './screenshots'
    end
  end
end