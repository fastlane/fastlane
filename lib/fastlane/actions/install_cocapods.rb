module Fastlane
  module Actions
    class CocoapodsAction
      def self.run(params)
        Actions.sh("pod install")
      end
    end
  end
end
