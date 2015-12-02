module Fastlane
  class Setup
    # Start the setup process
    def run
      platform = nil
      if is_ios?
        Helper.log.info "Detected iOS/Mac project in current directory..."
        platform = :ios
      elsif is_android?
        Helper.log.info "Detected Android project in current directory..."
        platform = :android
      else
        Helper.log.info "Couldn't automatically detect the platform"
        val = agree("Is this project an iOS project? (y/n) ".yellow, true)
        platform = (val ? :ios : :android)
      end

      if platform == :ios
        SetupIos.new.run
      elsif platform == :android
        SetupAndroid.new.run
      else
        raise "Couldn't find platform '#{platform}'"
      end
      FastlaneCore::CrashReporting.enable
    end

    def is_ios?
      (Dir["*.xcodeproj"] + Dir["*.xcworkspace"]).count > 0
    end

    def is_android?
      Dir["*.gradle"].count > 0
    end

    def show_analytics
      Helper.log.info "fastlane will send the number of errors for each action to"
      Helper.log.info "https://github.com/fastlane/enhancer to detect integration issues"
      Helper.log.info "No sensitive/private information will be uploaded"
      Helper.log.info("You can disable this by adding `opt_out_usage` to your Fastfile")
    end

    def ask_for_crash_reporting
      FastlaneCore::CrashReporting.ask_during_setup
    end
  end
end

require 'fastlane/setup/setup_ios'
require 'fastlane/setup/setup_android'
