module Snapshot
  module Fixes
    # This fix is needed due to a bug in UI Tests that creates invalid screenshots when the
    # simulator is not scaled to a 100%
    # Issue: https://github.com/fastlane/snapshot/issues/249
    # Radar: https://openradar.appspot.com/radar?id=6127019184095232

    class SimulatorZoomFix
      def self.patch
        Snapshot.kill_simulator # First we need to kill the simulator

        UI.message "Patching '#{config_path}' to scale simulator to 100%"

        FastlaneCore::Simulator.all.each do |simulator|
          simulator_name = simulator.name.tr("\s", "-")
          key = "SimulatorWindowLastScale-com.apple.CoreSimulator.SimDeviceType.#{simulator_name}"

          Helper.backticks("defaults write '#{config_path}' '#{key}' '1.0'", print: $verbose)
        end
      end

      def self.config_path
        File.join(File.expand_path("~"), "Library", "Preferences", "com.apple.iphonesimulator.plist")
      end
    end
  end
end
