module Fastlane
  module Actions
    class SharedFixtureAction < Action
      def self.run(params)
        UI.message("Shared fixture plugin action")
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
