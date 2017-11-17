module Fastlane
  module Actions
    require 'fastlane/actions/frameit'
    class FrameitAction < FrameScreenshotsAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `frame_screenshots` action"
      end
    end
  end
end
