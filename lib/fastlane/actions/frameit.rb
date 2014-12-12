module Fastlane
  module Actions
    def self.frameit(params)
      screenshots_folder = File.join(Fastlane::FastlaneFolder::path, self.snapshot_screenshots_folder)
      Dir.chdir(screenshots_folder) do
        sh 'frameit'
      end
    end
  end
end