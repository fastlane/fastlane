module Fastlane
  module Actions
    class SayAction < Action
      def self.run(params)
        text = params.join(' ')
        Actions.sh("say '#{text}'")
      end

      def self.description
        "This action speaks out loud the given text"
      end
    end
  end
end
