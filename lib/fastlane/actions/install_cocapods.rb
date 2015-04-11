module Fastlane
  module Actions
    class CocoapodsAction < Action
      def self.run(_params)
        Actions.sh('pod install')
      end
    end
  end
end
