module Fastlane
  class Setup
    # Start the setup process
    def run
      if FastlaneFolder.setup? and !Helper.is_test?
        UI.important("fastlane is already set up at path #{FastlaneFolder.path}")
        return
      end

      platform = nil
      if is_ios?
        UI.message("Detected iOS/Mac project in current directory...")
        platform = :ios
      elsif is_android?
        UI.message("Detected Android project in current directory...")
        platform = :android
      else
        UI.message("Couldn't automatically detect the platform")
        val = agree("Is this project an iOS project? (y/n) ".yellow, true)
        platform = (val ? :ios : :android)
      end

      if platform == :ios
        SetupIos.new.run
      elsif platform == :android
        SetupAndroid.new.run
      else
        UI.user_error!("Couldn't find platform '#{platform}'")
      end
    end

    def is_ios?
      (Dir["*.xcodeproj"] + Dir["*.xcworkspace"]).count > 0
    end

    def is_android?
      Dir["*.gradle"].count > 0
    end

    def show_analytics
      UI.message("fastlane will send the number of errors for each action to")
      UI.message("https://github.com/fastlane/enhancer to detect integration issues")
      UI.message("No sensitive/private information will be uploaded")
    end
  end
end

require 'fastlane/setup/setup_ios'
require 'fastlane/setup/setup_android'
require 'fastlane/setup/crashlytics_beta_ui'
require 'fastlane/setup/crashlytics_beta'
require 'fastlane/setup/crashlytics_project_parser'
require 'fastlane/setup/crashlytics_beta_info'
require 'fastlane/setup/crashlytics_beta_info_collector'
require 'fastlane/setup/crashlytics_beta_command_line_handler'
require 'fastlane/setup/crashlytics_beta_user_email_fetcher'
