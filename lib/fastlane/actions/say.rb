module Fastlane
  module Actions
    class SayAction < Action
      def self.run(params)
        text = params.join(" ")
        Actions.sh("say '#{text}'")
      end

      def self.description
        "This action speaks out loud the given text"
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
