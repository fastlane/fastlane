module Fastlane
  module Actions
    class CarthageAction
      
      def self.is_supported?(type)
        type == :ios
      end

      def self.run(_params)
        Actions.sh('carthage bootstrap')
      end
    end
  end
end
