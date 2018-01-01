module Fastlane
  class SetupIos < Setup
    # Reference to the iOS project
    attr_accessor :project

    # App Identifier of the current app
    attr_accessor :app_identifier

    # Scheme of the Xcode project
    attr_accessor :scheme

    # If the current setup requires a login, this is where we'll store the team ID
    attr_accessor :itc_team_id
    attr_accessor :adp_team_id


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
      ask_for_credentials(adp: true, itc: true)
      verify_app_exists_adp!
      verify_app_exists_itc!

      append_lane(["lane :beta do",
                   "  gym(scheme: \"#{self.scheme}\")",
                   "  upload_to_testflight",
                   "end"])
      finish_up
    end

    def ios_app_store
      UI.header("Setting up fastlane for iOS App Store distribution")
      find_and_setup_xcode_project
      ask_for_credentials(adp: true, itc: true)
      verify_app_exists_adp!
      verify_app_exists_itc!
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
      # TODO: can we find the username from the Xcode project?
    end

    def ask_for_credentials(itc: true, adp: false)
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

      if self.user.to_s.length == 0
        UI.important("Please enter your Apple ID developer credentials")
        self.user = UI.input("Apple ID Username:") # TODO: why does this render in new-line
      end

      # Disable the warning texts and information that's not relevant during onboarding
      ENV["FASTLANE_HIDE_LOGIN_INFORMATION"] = 1.to_s
      ENV["FASTLANE_HIDE_TEAM_INFORMATION"] = 1.to_s
      if itc
        Spaceship::Tunes.login(self.user)
        Spaceship::Tunes.select_team
        self.itc_team_id = Spaceship::Tunes.client.team_id
      end
      if adp
        Spaceship::Portal.login(self.user)
        Spaceship::Portal.select_team
        self.adp_team_id = Spaceship::Portal.client.team_id
      end
      UI.success("✅  Login with your Apple ID was successful")
    end

    def verify_app_exists_adp!
      UI.user_error!("No app identifier provided") if self.app_identifier.to_s.length == 0
      UI.message("Checking if the app '#{self.app_identifier}' exists on the Apple Developer Portal...")
      app = Spaceship::Portal::App.find(self.app_identifier)
      if app.nil?
        UI.error("Looks like the app '#{self.app_identifier}' isn't available on the Apple Developer Portal")
        UI.error("for the team ID '#{self.adp_team_id}' on Apple ID '#{self.user}'")
        
        if UI.confirm("Do you want fastlane to create the App ID for you on the Apple Developer Portal?")
          require 'produce'
          produce_options = {
            username: self.user,
            team_id: self.adp_team_id,
            skip_itc: true,
            platform: "ios",
            app_identifier: self.app_identifier
          }
          Produce.config = FastlaneCore::Configuration.create(
            Produce::Options.available_options, 
            produce_options
          )

          # The retrying system allows people to correct invalid inputs
          # e.g. the app's name is already taken
          loop do
            begin
              result = Produce::Manager.start_producing
            rescue => ex
              # show the user facing error, and inform them of what went wrong
              if ex.kind_of?(Spaceship::Client::BasicPreferredInfoError) || ex.kind_of?(Spaceship::Client::UnexpectedResponse)
                UI.error(ex.preferred_error_info)
              else
                UI.error(ex.to_s)
              end
              UI.error(ex.backtrace.join("\n")) if FastlaneCore::Globals.verbose?
              UI.important("Looks like something went wrong when trying to create the app on the Apple Developer Portal")
              unless UI.confirm("Do you want to try again (y)? If you enter (n), fastlane will fall back to the manual setup")
                ios_manual
                return # TODO: fail out somehow, this will return the initial process instead
              end
            end
          end
        else
          UI.error("User declined... falling back to manual fastlane setup")
          ios_manual
          # TODO: fail out somehow, this will return the initial process instead
        end
      else
        UI.success("✅  Your app '#{self.app_identifier.yellow}' is available on iTunes Connect")
      end
    end

    def verify_app_exists_itc!
      UI.user_error!("No app identifier provided") if self.app_identifier.to_s.length == 0
      UI.message("Checking if the app '#{self.app_identifier}' exists on iTunes Connect...")
      app = Spaceship::Tunes::Application.find(self.app_identifier)
      if app.nil?
        UI.error("Looks like the app '#{self.app_identifier}' isn't available on iTunes Connect")
        UI.error("for the team ID '#{self.itc_team_id}' on Apple ID '#{self.user}'")
        UI.message("Do you want fastlane to create the App on iTunes Connect for you?")
      else
        UI.success("✅  Your app '#{self.app_identifier.yellow}' is available on iTunes Connect")
      end
    end
  end
end
