module Fastlane
  module Actions
    class ResetSimulatorContentsAction < Action
      def self.run(params)
        if Helper.xcode_at_least?("9")
          UI.important("Resetting simulators currently doesn't work with Xcode 9, stay tuned as we are working to add support for all new tools.")
          return
        end

        if params[:ios]
          params[:ios].each do |os_version|
            FastlaneCore::Simulator.reset_all_by_version(os_version: os_version)
          end
        else
          FastlaneCore::Simulator.reset_all
        end
        UI.success('Simulators reset')
      end

      def self.description
        "Shutdown and reset running simulators"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ios,
                                       short_option: "-i",
                                       env_name: "FASTLANE_RESET_SIMULATOR_VERSIONS",
                                       description: "Which versions of Simulators you want to reset content and settings, this does not remove/recreate the simulators",
                                       is_string: false,
                                       optional: true,
                                       type: Array)
        ]
      end

      def self.aliases
        ["reset_simulators"]
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
          'reset_simulator_contents'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
