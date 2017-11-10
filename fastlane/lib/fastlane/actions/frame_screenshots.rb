module Fastlane
  module Actions
    require 'fastlane/actions/frameit'
    class FrameScreenshotsAction < FrameitAction

      def self.run(config)
        UI.message "Framing screenshots using frameit"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Adds a black frame around all screenshots (via frameit)"
      end
    end
  end
end
