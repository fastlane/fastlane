module Snapshot
  class DependencyChecker
    def self.check_dependencies
      return if Helper.test?

      self.check_xcode_select
      self.check_simctl
    end

    def self.check_xcode_select
      unless `xcode-select -v`.include? "xcode-select version"
        UI.error '#############################################################'
        UI.error "# You have to install Xcode command line tools to use snapshot"
        UI.error "# Install the latest version of Xcode from the AppStore"
        UI.error "# Run xcode-select --install to install the developer tools"
        UI.error '#############################################################'
        UI.user_error!("Run 'xcode-select --install' and start snapshot again")
      end

      if Snapshot::LatestOsVersion.ios_version.to_f < 9 # to_f is bad, but should be good enough
        UI.error '#############################################################'
        UI.error "# Your xcode-select Xcode version is below 7.0"
        UI.error "# To use snapshot 1.0 and above you need at least iOS 9"
        UI.error "# Set the path to the Xcode version that supports UI Tests"
        UI.error "# or downgrade to versions older than snapshot 1.0"
        UI.error '#############################################################'
        UI.user_error!("Run 'sudo xcode-select -s /Applications/Xcode-beta.app'")
      end
    end

    def self.check_simulators
      UI.verbose("Found #{FastlaneCore::Simulator.all.count} simulators.")
      if FastlaneCore::Simulator.all.count == 0
        UI.error '#############################################################'
        UI.error "# You have to add new simulators using Xcode"
        UI.error "# You can let snapshot create new simulators: 'snapshot reset_simulators'"
        UI.error "# Manually: Xcode => Window => Devices"
        UI.error "# Please run `instruments -s` to verify your xcode path"
        UI.error '#############################################################'
        UI.user_error!("Create the new simulators and run this script again")
      end
    end

    def self.check_simctl
      unless `xcrun simctl`.include? "openurl"
        UI.user_error!("Could not find `xcrun simctl`. Make sure you have the latest version of Xcode and macOS installed.")
      end
    end
  end
end
