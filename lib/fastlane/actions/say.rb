module Fastlane
  module Actions
    class SayAction < Action
      def self.run(params)
        text = params.join(' ')
        Actions.sh("say '#{text}'")
      end
    end
  end
end
