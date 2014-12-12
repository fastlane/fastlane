module Fastlane
  module Actions
    def self.deliver(params)
      ENV["DELIVER_SCREENSHOTS_PATH"] = self.snapshot_screenshots_folder
      sh "deliver --force"
    end
  end
end