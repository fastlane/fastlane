module Fastlane
  module Actions
    class ActionFromActionInvalidAction < Action
      def self.run(params)
        return rocket # no `other_action` will fail
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
