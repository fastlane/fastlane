module Fastlane
  module Actions
    class ActionFromActionAction < Action
      def self.run(params)
        return other_action.rocket
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
