module Fastlane
  module Actions
    class StepTextCustomWithParamsAction < Action
      def self.run(params)
        UI.important("run")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :task,
                                       description: "Task to be printed out")
        ]
      end

      def self.is_supported?(platform)
        true
      end

      def self.step_text(params)
        "Doing #{params[:task]}"
      end
    end
  end
end
