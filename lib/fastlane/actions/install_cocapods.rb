module Fastlane
  module Actions
    class CocoapodsAction < Action
      def self.run(_params)
        Actions.sh("pod install")
      end

      def self.description
        "Runs `pod install` for the project"
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
