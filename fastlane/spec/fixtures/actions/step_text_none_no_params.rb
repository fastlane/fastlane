module Fastlane
  module Actions
    class StepTextNoneNoParamsAction < Action
      def self.run(params)
        UI.important("run")
      end

      def self.is_supported?(platform)
        true
      end

      def self.step_text
        nil
      end
    end
  end
end
