module Fastlane
  module Actions
    class BrokenAction
      # Missing method
      def self.is_supported?(platform)
        true
      end
    end
  end
end
