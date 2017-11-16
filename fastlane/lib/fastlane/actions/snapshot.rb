module Fastlane
  module Actions
    require 'fastlane/actions/capture_ios_screenshots'
    class SnapshotAction < CaptureIOSScreenshotsAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `capture_ios_screenshots` action"
      end
    end
  end
end
