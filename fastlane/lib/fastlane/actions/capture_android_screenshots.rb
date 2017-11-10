module Fastlane
  module Actions
    require 'fastlane/actions/screengrab'
    class CreateAndroidScreenshotsAction < ScreengrabAction
      def self.run(config)
        UI.message "Taking screenshots using sceengrab"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Take new screenshots (via screengrab), based on the Screengrabfile"
      end
    end
  end
end
