module Fastlane
  module Actions
    require 'fastlane/actions/snapshot'
    class CaptureIOSScreenshotsAction < SnapshotAction

      def self.run(config)
        UI.message "Taking screenshots using snapshot"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Take new screenshots (via snapshot), based on the Snapfile"
      end
    end
  end
end
