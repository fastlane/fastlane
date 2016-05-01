module Fastlane
  module Actions
    class ActionFromActionAction < Action
      def self.run(params)
        return rocket
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
