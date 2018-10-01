module Fastlane
  module Actions
    require_relative 'capture_ios_screenshots'
    class CaptureScreenshotsAction < CaptureIosScreenshotsAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `capture_ios_screenshots` action"
      end
    end
  end
end
