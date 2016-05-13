module Fastlane
  module Actions
    class ActionFromActionAction < Action
      def self.run(params)
        return {
          rocket: other_action.rocket,
          pwd: other_action.pwd
        }
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
