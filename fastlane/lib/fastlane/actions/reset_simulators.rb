module Fastlane
  module Actions
    class ResetSimulatorsAction < Action
      def self.run(params)
        if params[:ios]
          params[:ios].each do |os_version|
            FastlaneCore::Simulator.all.each do |dev|
              if dev.os_version == os_version
                dev.reset
              end
            end
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
                                       description: "Which versions of Simulators you want to reset",
                                       is_string: false,
                                       optional: true,
                                       type: Array)
        ]
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
