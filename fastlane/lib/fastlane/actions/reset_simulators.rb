module Fastlane
  module Actions
    class ResetSimulatorsAction < Action
      def self.run(params)
        FastlaneCore::Simulator.reset_all
        UI.success('Simulators reset')
      end

      def self.description
        "Shutdown and reset running simulators"
      end

      def self.available_options
        []
      end

      def self.output
        nil
      end

      def self.return_value
        nil
      end

      def self.authors
        ["danramteke"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'reset_simulators'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
