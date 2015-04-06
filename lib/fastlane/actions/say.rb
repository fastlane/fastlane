module Fastlane
  module Actions
    class SayAction

      def self.is_supported?(type)
        true
      end

      def self.run(params)
        text = params.join(' ')
        Actions.sh("say '#{text}'")
      end
    end
  end
end
