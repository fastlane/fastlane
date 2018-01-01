module Fastlane
  class SetupIos < Setup
    # Reference to the iOS project
    attr_accessor :project

    # App Identifier of the current app
    attr_accessor :app_identifier

    # Scheme of the Xcode project
    attr_accessor :scheme

    def setup_ios
      require 'spaceship'

      self.platform = :ios
      self.fastfile_content = fastfile_template_content

      welcome_to_fastlane

      options = {
        "📸  Automate screenshots" => :ios_screenshots,
        "👩‍✈️  Automate beta distribution to TestFlight" => :ios_testflight,
        "🚀  Automate App Store distribution" => :ios_app_store,
        "🛠  Manual setup - setup your project to manually automate your tasks" => :ios_manual
      }

      selected = UI.select("What do you want to use fastlane for?", options.keys)
      method_to_use = options[selected]
      self.send(method_to_use)
    end

    # Different iOS flows
    def ios_testflight
      UI.header("Setting up fastlane for iOS TestFlight distribution")
      find_and_setup_xcode_project
      ask_for_credentials

      append_lane(["lane :beta do",
                   "  gym(scheme: \"#{self.scheme}\")",
                   "  upload_to_testflight",
                   "end"])
      finish_up
    end

    def ios_app_store
      UI.header("Setting up fastlane for iOS App Store distribution")
      find_and_setup_xcode_project
    end

    def ios_screenshots
      UI.header("Setting up fastlane to automate iOS screenshots")
    end

    def ios_manual
      UI.header("Setting up fastlane, the manual way")
      append_lane(["lane :custom_lane do",
                   "  # add actions here: https://docs.fastlane.tools/actions",
                   "end"])
      finish_up
    end

    # Helpers

    # Every installation setup that needs an Xcode project should
    # call this method
    def find_and_setup_xcode_project
      UI.message("Parsing your local Xcode project to find the available schemes and the app identifier")
      config = {} # this is needed as the first method call will store information in there
      FastlaneCore::Project.detect_projects(config)
      self.project = FastlaneCore::Project.new(config)
      self.scheme = self.project.select_scheme(preferred_to_include: self.project.project_name)
      self.app_identifier = self.project.default_app_identifier # These two vars need to be accessed in order to be set
    end

    def ask_for_credentials(username: nil)
      UI.header("Login with your Apple ID")
      UI.message("To use iTunes Connect and Apple Developer Portal features as part of fastlane,")
      UI.message("we will ask you for your Apple ID username and password")
      UI.message("This is necessary to use certain fastlane features, for example:")
      UI.message("")
      UI.message("- Create and manage your provisioning profiles on the Developer Portal")
      UI.message("- Upload and manage TestFlight and App Store builds on iTunes Connect")
      UI.message("- Manage your iTunes Connect app metadata and screenshots")
      UI.message("")
      UI.message("Your Apple ID credentials will only be stored on your local machine, in the Keychain")
      UI.message("For more information, check out")
      UI.message("\thttps://github.com/fastlane/fastlane/tree/master/credentials_manager".cyan)
      UI.message("")
      UI.important("Please enter your Apple ID developer account username and password:")

      # Disable the warning texts and information that's not relevant during onboarding
      ENV["FASTLANE_HIDE_LOGIN_INFORMATION"] = 1.to_s
      ENV["FASTLANE_HIDE_TEAM_INFORMATION"] = 1.to_s
      Spaceship::Tunes.login(username)
      Spaceship::Tunes.select_team
      UI.success("Login with your Apple ID was successful")
    end
  end
end
