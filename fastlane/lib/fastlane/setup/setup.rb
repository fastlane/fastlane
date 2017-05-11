module Fastlane
  class Setup
    # Start the setup process
    def run(user: nil)
      if FastlaneCore::FastlaneFolder.setup? and !Helper.is_test?
        UI.important("fastlane is already set up at path #{FastlaneCore::FastlaneFolder.path}")
        return
      end

      platform = nil
      if is_ios?
        UI.message("Detected iOS/Mac project in current directory...")
        platform = :ios
      elsif is_android?
        UI.message("Detected Android project in current directory...")
        platform = :android
      elsif is_react_native?
        UI.important("Detected react-native app. To set up fastlane, please run")
        UI.command("fastlane init")
        UI.important("in the sub-folder for each platform (\"ios\" or \"android\")")
        UI.user_error!("Please navigate to the platform subfolder and run `fastlane init` again")
      else
        UI.important("Couldn't automatically detect the platform")
        val = UI.confirm("Is this project an iOS project?")
        platform = (val ? :ios : :android)
      end

      if platform == :ios
        SetupIos.new.run(user: user)
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

    def is_react_native?
      SetupIos.project_uses_react_native?(path: "./ios")
    end

    def show_analytics
      UI.message("fastlane will collect the number of errors for each action to detect integration issues")
      UI.message("No sensitive/private information will be uploaded")
      UI.message("Learn more at https://github.com/fastlane/fastlane#metrics")
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
