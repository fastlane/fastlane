module Fastlane
  module Actions
    class CarthageAction < Action
      def self.run(_params)
        Actions.sh('carthage bootstrap')
      end

      def self.description
        "Runs `carthage bootstrap` for your project"
      end

      def self.author
        "bassrock"
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
