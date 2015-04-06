module Fastlane
  module Actions
    class CocoapodsAction
      
      def self.is_supported?(type)
        type == :ios
      end

      def self.run(_params)
        Actions.sh('pod install')
      end
    end
  end
end
