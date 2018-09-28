module Fastlane
  module Actions
    require_relative internal('fastlane/actions/capture_android_screenshots')
    class ScreengrabAction < CaptureAndroidScreenshotsAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `capture_android_screenshots` action"
      end
    end
  end
end
