module Fastlane
  module Actions
    require 'fastlane/actions/gym'
    class BuildAppAction < GymAction
      def self.run(config)
        UI.message "Building your app using gym"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Build your iOS/macOS app (via gym)"
      end
    end
  end
end
