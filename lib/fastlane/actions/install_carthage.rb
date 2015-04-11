module Fastlane
  module Actions
    class CarthageAction < Action
      def self.run(_params)
        Actions.sh('carthage bootstrap')
      end
    end
  end
end
