module Fastlane
  module Actions
    class CocoapodsAction < Action
      def self.run(params)
        Actions.sh('pod install')
      end

      def self.description
        "Runs `pod install` for the project"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?platform
      end
    end
  end
end
