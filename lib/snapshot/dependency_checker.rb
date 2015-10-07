module Snapshot
  class DependencyChecker
    def self.check_dependencies
      self.check_xcode_select
      self.check_simctl
    end

    def self.check_xcode_select
      unless `xcode-select -v`.include? "xcode-select version"
        Helper.log.fatal '#############################################################'
        Helper.log.fatal "# You have to install the Xcode commdand line tools to use snapshot"
        Helper.log.fatal "# Install the latest version of Xcode from the AppStore"
        Helper.log.fatal "# Run xcode-select --install to install the developer tools"
        Helper.log.fatal '#############################################################'
        raise "Run 'xcode-select --install' and start snapshot again"
      end

      if Snapshot::LatestIosVersion.version.to_f < 9 # to_f is bad, but should be good enough
        Helper.log.fatal '#############################################################'
        Helper.log.fatal "# Your xcode-select Xcode version is below 9.0"
        Helper.log.fatal "# To use snapshot 1.0 and above you need at leat iOS 9"
        Helper.log.fatal "# Set the path to the Xcode version that supports UI Tests"
        Helper.log.fatal "# or downgrade to versions older than snapshot 1.0"
        Helper.log.fatal '#############################################################'
        raise "Run 'sudo xcode-select -s /Applications/Xcode-beta.app'"
      end
    end

    def self.check_simulators
      Helper.log.debug "Found #{Simulator.all.count} simulators." if $verbose
      if Simulator.all.count < 1
        Helper.log.fatal '#############################################################'
        Helper.log.fatal "# You have to add new simulators using Xcode"
        Helper.log.fatal "# You can let snapshot create new simulators: 'snapshot reset_simulators'"
        Helper.log.fatal "# Manually: Xcode => Window => Devices"
        Helper.log.fatal "# Please run `instruments -s` to verify your xcode path"
        Helper.log.fatal '#############################################################'
        raise "Create the new simulators and run this script again"
      end
    end

    def self.check_simctl
      unless `xcrun simctl`.include? "openurl"
        raise "Could not find `xcrun simctl`. Make sure you have the latest version of Xcode and Mac OS installed.".red
      end
    end
  end
end
