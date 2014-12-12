module Fastlane
  module Actions
    def self.snapshot(params)
      ENV['SNAPSHOT_SCREENSHOTS_PATH'] = './screenshots'
      sh "snapshot"
    end
  end
end