module Snapshot
  class DependencyChecker
    def self.check_dependencies
      self.check_xcode_select
      self.check_xctool
      self.check_for_automation_subfolder
      self.check_simctl
    end

    def self.check_xcode_select
      unless `xcode-select -v`.include?"xcode-select version "
        Helper.log.fatal '#############################################################'
        Helper.log.fatal "# You have to install the Xcode commdand line tools to use snapshot"
        Helper.log.fatal "# Install the latest version of Xcode from the AppStore"
        Helper.log.fatal "# Run xcode-select --install to install the developer tools"
        Helper.log.fatal '#############################################################'
        raise "Run 'xcode-select --install' and start snapshot again"
      end
    end

    def self.check_simulators
      Helper.log.debug "Found #{Simulators.available_devices.count} simulators." if $verbose
      if Simulators.available_devices.count < 1
        Helper.log.fatal '#############################################################'
        Helper.log.fatal "# You have to add new simulators using Xcode"
        Helper.log.fatal "# You can let snapshot create new simulators: 'snapshot reset_simulators'"
        Helper.log.fatal "# Manually: Xcode => Window => Devices"
        Helper.log.fatal "# Please run `instruments -s` to verify your xcode path"
        Helper.log.fatal '#############################################################'
        raise "Create the new simulators and run this script again"
      end
    end

    def self.xctool_installed?
      return `which xctool`.length > 1
    end

    def self.check_xctool
      if not self.xctool_installed?
        Helper.log.info '#############################################################'
        Helper.log.info "# xctool is recommended to build the apps"
        Helper.log.info "# Install it using 'brew install xctool'"
        Helper.log.info "# Falling back to xcodebuild instead "
        Helper.log.info '#############################################################'
      end
    end

    def self.check_for_automation_subfolder
      if File.directory?"./Automation" or File.exists?"./Automation"
        raise "Seems like you have an 'Automation' folder in the current directory. You need to delete/rename it!".red
      end
    end

    def self.check_simctl
      unless `xcrun simctl`.include?"openurl"
        raise "Could not find `xcrun simctl`. Make sure you have the latest version of Xcode and Mac OS installed.".red
      end
    end
  end
end
