module Fastlane
  # rubocop:disable Metrics/ClassLength
  class SetupIos < Setup
    # Reference to the iOS project `project.rb`
    attr_accessor :project

    # App Identifier of the current app
    attr_accessor :app_identifier

    # Scheme of the Xcode project
    attr_accessor :scheme

    # If the current setup requires a login, this is where we'll store the team ID
    attr_accessor :itc_team_id
    attr_accessor :adp_team_id

    attr_accessor :app_exists_on_itc

    attr_accessor :automatic_versioning_enabled

    def setup_ios
      require 'spaceship'

      self.platform = :ios

      welcome_to_fastlane

      self.fastfile_content = fastfile_template_content
      self.appfile_content = appfile_template_content

      if preferred_setup_method
        self.send(preferred_setup_method)

        return
      end

      options = {
        "📸  Automate screenshots" => :ios_screenshots,
        "👩‍✈️  Automate beta distribution to TestFlight" => :ios_testflight,
        "🚀  Automate App Store distribution" => :ios_app_store,
        "🛠  Manual setup - manually setup your project to automate your tasks" => :ios_manual
      }

      selected = UI.select("What would you like to use fastlane for?", options.keys)
      @method_to_use = options[selected]

      begin
        self.send(@method_to_use)
      rescue => ex
        # If it's already manual, and it has failed
        # we need to re-raise the exception, as something definitely is wrong
        raise ex if @method_to_use == :ios_manual

        # If we're here, that means something else failed. We now show the
        # error message and fallback to `:ios_manual`
        UI.error("--------------------")
        UI.error("fastlane init failed")
        UI.error("--------------------")

        UI.verbose(ex.backtrace.join("\n"))
        if ex.kind_of?(Spaceship::Client::BasicPreferredInfoError) || ex.kind_of?(Spaceship::Client::UnexpectedResponse)
          UI.error(ex.preferred_error_info)
        else
          UI.error(ex.to_s)
        end

        UI.important("Something failed while running `fastlane init`")
        UI.important("Tried using Apple ID with email '#{self.user}'")
        UI.important("You can either retry, or fallback to manual setup which will create a basic Fastfile")
        if UI.confirm("Would you like to fallback to a manual Fastfile?")
          self.ios_manual
        else
          self.send(@method_to_use)
        end
        # the second time, we're just failing, and don't use a `begin` `rescue` block any more
      end
    end

    # Different iOS flows
    def ios_testflight
      UI.header("Setting up fastlane for iOS TestFlight distribution")
      find_and_setup_xcode_project
      apple_xcode_project_versioning_enabled
      ask_for_credentials(adp: true, itc: true)
      verify_app_exists_adp!
      verify_app_exists_itc!

      if self.is_swift_fastfile
        lane = ["func betaLane() {",
                "desc(\"Push a new beta build to TestFlight\")",
                increment_build_number_if_applicable,
                "\tbuildApp(#{project_prefix}scheme: \"#{self.scheme}\")",
                "\tuploadToTestflight(username: \"#{self.user}\")",
                "}"]
      else
        lane = ["desc \"Push a new beta build to TestFlight\"",
                "lane :beta do",
                increment_build_number_if_applicable,
                "  build_app(#{project_prefix}scheme: \"#{self.scheme}\")",
                "  upload_to_testflight",
                "end"]
      end
      self.append_lane(lane)

      self.lane_to_mention = "beta"
      finish_up
    end

    def ios_app_store
      UI.header("Setting up fastlane for iOS App Store distribution")
      find_and_setup_xcode_project
      apple_xcode_project_versioning_enabled
      ask_for_credentials(adp: true, itc: true)
      verify_app_exists_adp!
      verify_app_exists_itc!

      if self.app_exists_on_itc
        UI.header("Manage app metadata?")
        UI.message("Would you like to have fastlane manage your app's metadata?")
        UI.message("If you enable this feature, fastlane will download your existing metadata and screenshots.")
        UI.message("This way, you'll be able to edit your app's metadata in local `.txt` files.")
        UI.message("After editing the local `.txt` files, just run fastlane and all changes will be pushed up.")
        UI.message("If you don't want to use this feature, you can still use fastlane to upload and distribute new builds to the App Store")
        include_metadata = UI.confirm("Would you like fastlane to manage your app's metadata?")
        if include_metadata
          require 'deliver'
          require 'deliver/setup'

          deliver_options = FastlaneCore::Configuration.create(
            Deliver::Options.available_options,
            {
              run_precheck_before_submit: false, # precheck doesn't need to run during init
              username: self.user,
              app_identifier: self.app_identifier,
              team_id: self.itc_team_id
            }
          )

          Deliver::DetectValues.new.run!(deliver_options, {}) # needed to fetch the app details
          Deliver::Setup.new.run(deliver_options, is_swift: self.is_swift_fastfile)
        end
      end

      if self.is_swift_fastfile
        lane = ["func releaseLane() {",
                "desc(\"Push a new release build to the App Store\")",
                increment_build_number_if_applicable,
                "\tbuildApp(#{project_prefix}scheme: \"#{self.scheme}\")"]
        if include_metadata
          lane << "\tuploadToAppStore(username: \"#{self.user}\", app: \"#{self.app_identifier}\")"
        else
          lane << "\tuploadToAppStore(username: \"#{self.user}\", app: \"#{self.app_identifier}\", skipScreenshots: true, skipMetadata: true)"
        end
        lane << "}"
      else
        lane = ["desc \"Push a new release build to the App Store\"",
                "lane :release do",
                increment_build_number_if_applicable,
                "  build_app(#{project_prefix}scheme: \"#{self.scheme}\")"]
        if include_metadata
          lane << "  upload_to_app_store"
        else
          lane << "  upload_to_app_store(skip_metadata: true, skip_screenshots: true)"
        end
        lane << "end"
      end

      append_lane(lane)
      self.lane_to_mention = "release"
      finish_up
    end

    def ios_screenshots
      UI.header("Setting up fastlane to automate iOS screenshots")

      UI.message("fastlane uses UI Tests to automate generating localized screenshots of your iOS app")
      UI.message("fastlane will now create 2 helper files that are needed to get the setup running")
      UI.message("For more information on how this works and best practices, check out")
      UI.message("\thttps://docs.fastlane.tools/getting-started/ios/screenshots/".cyan)
      continue_with_enter

      begin
        find_and_setup_xcode_project(ask_for_scheme: false) # to get the bundle identifier
      rescue => ex
        # If this fails, it's no big deal, since we really just want the bundle identifier
        # so instead, we'll just ask the user
        UI.verbose(ex.to_s)
      end

      require 'snapshot'
      require 'snapshot/setup'

      Snapshot::Setup.create(
        FastlaneCore::FastlaneFolder.path,
        is_swift_fastfile: self.is_swift_fastfile,
        print_instructions_on_failure: true
      )

      UI.message("If you want more details on how to setup automatic screenshots, check out")
      UI.message("\thttps://docs.fastlane.tools/getting-started/ios/screenshots/#setting-up-snapshot".cyan)
      continue_with_enter

      available_schemes = self.project.schemes
      ui_testing_scheme = UI.select("Which is your UI Testing scheme? If you can't find it in this list, make sure it's marked as `Shared` in the Xcode scheme list", available_schemes)

      UI.header("Automatically upload to iTC?")
      UI.message("Would you like fastlane to automatically upload all generated screenshots to App Store Connect")
      UI.message("after generating them?")
      UI.message("If you enable this feature you'll need to provide your App Store Connect credentials so fastlane can upload the screenshots to App Store Connect")
      automatic_upload = UI.confirm("Enable automatic upload of localized screenshots to App Store Connect?")
      if automatic_upload
        ask_for_credentials(adp: true, itc: true)
        verify_app_exists_itc!
      end

      if self.is_swift_fastfile
        lane = ["func screenshotsLane() {",
                "desc(\"Generate new localized screenshots\")",
                "\tcaptureScreenshots(#{project_prefix}scheme: \"#{ui_testing_scheme}\")"]

        if automatic_upload
          lane << "\tuploadToAppStore(username: \"#{self.user}\", app: \"#{self.app_identifier}\", skipBinaryUpload: true, skipMetadata: true)"
        end
        lane << "}"
      else
        lane = ["desc \"Generate new localized screenshots\"",
                "lane :screenshots do",
                "  capture_screenshots(#{project_prefix}scheme: \"#{ui_testing_scheme}\")"]

        if automatic_upload
          lane << "  upload_to_app_store(skip_binary_upload: true, skip_metadata: true)"
        end
        lane << "end"
      end
      append_lane(lane)

      self.lane_to_mention = "screenshots"
      finish_up
    end

    def ios_manual
      UI.header("Setting up fastlane so you can manually configure it")

      if self.is_swift_fastfile
        append_lane(["func customLane() {",
                     "desc(\"Description of what the lane does\")",
                     "\t// add actions here: https://docs.fastlane.tools/actions",
                     "}"])
        self.lane_to_mention = "custom" # lane is part of the notation
      else
        append_lane(["desc \"Description of what the lane does\"",
                     "lane :custom_lane do",
                     "  # add actions here: https://docs.fastlane.tools/actions",
                     "end"])
        self.lane_to_mention = "custom_lane"
      end

      finish_up
    end

    # Helpers

    # Every installation setup that needs an Xcode project should
    # call this method
    def find_and_setup_xcode_project(ask_for_scheme: true)
      UI.message("Parsing your local Xcode project to find the available schemes and the app identifier")
      config = {} # this is needed as the first method call will store information in there
      if self.project_path.end_with?("xcworkspace")
        config[:workspace] = self.project_path
      else
        config[:project] = self.project_path
      end

      FastlaneCore::Project.detect_projects(config)
      self.project = FastlaneCore::Project.new(config)

      if ask_for_scheme
        self.scheme = self.project.select_scheme(preferred_to_include: self.project.project_name)
      end

      self.app_identifier = self.project.default_app_identifier # These two vars need to be accessed in order to be set
      if self.app_identifier.to_s.length == 0
        ask_for_bundle_identifier
      end
    end

    def ask_for_bundle_identifier
      loop do
        return if self.app_identifier.to_s.length > 0
        self.app_identifier = UI.input("Bundle identifier of your app: ")
      end
    end

    def ask_for_credentials(itc: true, adp: false)
      UI.header("Login with your Apple ID")
      UI.message("To use App Store Connect and Apple Developer Portal features as part of fastlane,")
      UI.message("we will ask you for your Apple ID username and password")
      UI.message("This is necessary for certain fastlane features, for example:")
      UI.message("")
      UI.message("- Create and manage your provisioning profiles on the Developer Portal")
      UI.message("- Upload and manage TestFlight and App Store builds on App Store Connect")
      UI.message("- Manage your App Store Connect app metadata and screenshots")
      UI.message("")
      UI.message("Your Apple ID credentials will only be stored in your Keychain, on your local machine")
      UI.message("For more information, check out")
      UI.message("\thttps://github.com/fastlane/fastlane/tree/master/credentials_manager".cyan)
      UI.message("")

      if self.user.to_s.length == 0
        UI.important("Please enter your Apple ID developer credentials")
        self.user = UI.input("Apple ID Username:")
      end
      UI.message("Logging in...")

      # Disable the warning texts and information that's not relevant during onboarding
      ENV["FASTLANE_HIDE_LOGIN_INFORMATION"] = 1.to_s
      ENV["FASTLANE_HIDE_TEAM_INFORMATION"] = 1.to_s

      if itc
        Spaceship::Tunes.login(self.user)
        Spaceship::Tunes.select_team
        self.itc_team_id = Spaceship::Tunes.client.team_id
        if self.is_swift_fastfile
          self.append_team("var itcTeam: String? { return \"#{self.itc_team_id}\" } // App Store Connect Team ID")
        else
          self.append_team("itc_team_id(\"#{self.itc_team_id}\") # App Store Connect Team ID")
        end
      end

      if adp
        Spaceship::Portal.login(self.user)
        Spaceship::Portal.select_team
        self.adp_team_id = Spaceship::Portal.client.team_id
        if self.is_swift_fastfile
          self.append_team("var teamID: String { return \"#{self.adp_team_id}\" } // Apple Developer Portal Team ID")
        else
          self.append_team("team_id(\"#{self.adp_team_id}\") # Developer Portal Team ID")
        end
      end

      UI.success("✅  Logging in with your Apple ID was successful")
    end

    def apple_xcode_project_versioning_enabled
      self.automatic_versioning_enabled = false

      paths = self.project.project_paths
      return false if paths.count == 0

      result = Fastlane::Actions::GetBuildNumberAction.run({
        project: paths.first, # most of the times, there will only be one project in there
        hide_error_when_versioning_disabled: true
      })

      if result.kind_of?(String) && result.to_f > 0
        self.automatic_versioning_enabled = true
      end
      return self.automatic_versioning_enabled
    end

    def show_information_about_version_bumps
      UI.important("It looks like your project isn't set up to do automatic version incrementing")
      UI.important("To enable fastlane to handle automatic version incrementing for you, please follow this guide:")
      UI.message("\thttps://developer.apple.com/library/content/qa/qa1827/_index.html".cyan)
      UI.important("Afterwards check out the fastlane docs on how to set up automatic build increments")
      UI.message("\thttps://docs.fastlane.tools/getting-started/ios/beta-deployment/#best-practices".cyan)
    end

    def verify_app_exists_adp!
      UI.user_error!("No app identifier provided") if self.app_identifier.to_s.length == 0
      UI.message("Checking if the app '#{self.app_identifier}' exists in your Apple Developer Portal...")
      app = Spaceship::Portal::App.find(self.app_identifier)
      if app.nil?
        UI.error("It looks like the app '#{self.app_identifier}' isn't available on the #{'Apple Developer Portal'.bold.underline}")
        UI.error("for the team ID '#{self.adp_team_id}' on Apple ID '#{self.user}'")

        if UI.confirm("Do you want fastlane to create the App ID for you on the Apple Developer Portal?")
          create_app_online!(mode: :adp)
        else
          UI.important("Alright, we won't create the app for you. Be aware, the build is probably going to fail when you try it")
        end
      else
        UI.success("✅  Your app '#{self.app_identifier}' is available in your Apple Developer Portal")
      end
    end

    def verify_app_exists_itc!
      UI.user_error!("No app identifier provided") if self.app_identifier.to_s.length == 0
      UI.message("Checking if the app '#{self.app_identifier}' exists on App Store Connect...")
      app = Spaceship::Tunes::Application.find(self.app_identifier)
      if app.nil?
        UI.error("Looks like the app '#{self.app_identifier}' isn't available on #{'App Store Connect'.bold.underline}")
        UI.error("for the team ID '#{self.itc_team_id}' on Apple ID '#{self.user}'")
        if UI.confirm("Would you like fastlane to create the App on App Store Connect for you?")
          create_app_online!(mode: :itc)
          self.app_exists_on_itc = true
        else
          UI.important("Alright, we won't create the app for you. Be aware, the build is probably going to fail when you try it")
        end
      else
        UI.success("✅  Your app '#{self.app_identifier}' is available on App Store Connect")
        self.app_exists_on_itc = true
      end
    end

    def finish_up
      # iOS specific things first
      if self.app_identifier
        self.appfile_content.gsub!("# app_identifier", "app_identifier")
        self.appfile_content.gsub!("[[APP_IDENTIFIER]]", self.app_identifier)
      end

      if self.user
        self.appfile_content.gsub!("# apple_id", "apple_id")
        self.appfile_content.gsub!("[[APPLE_ID]]", self.user)
      end

      if !self.automatic_versioning_enabled && @method_to_use != :ios_manual
        self.show_information_about_version_bumps
      end

      super
    end

    # Returns the `workspace` or `project` key/value pair for
    # gym and snapshot, but only if necessary
    #     (when there are multiple projects in the current directory)
    # it's a prefix, and not a suffix, as Swift cares about the order of parameters
    def project_prefix
      return "" unless self.had_multiple_projects_to_choose_from

      if self.project_path.end_with?(".xcworkspace")
        return "workspace: \"#{self.project_path}\", "
      else
        return "project: \"#{self.project_path}\", "
      end
    end

    def increment_build_number_if_applicable
      return nil unless self.automatic_versioning_enabled
      return nil if self.project.project_paths.first.to_s.length == 0

      project_path = self.project.project_paths.first
      # Convert the absolute path to a relative path
      project_path_name = Pathname.new(project_path)
      current_path_name = Pathname.new(File.expand_path("."))

      relative_project_path = project_path_name.relative_path_from(current_path_name)

      if self.is_swift_fastfile
        return "\tincrementBuildNumber(xcodeproj: \"#{relative_project_path}\")"
      else
        return "  increment_build_number(xcodeproj: \"#{relative_project_path}\")"
      end
    end

    def create_app_online!(mode: nil)
      # mode is either :adp or :itc
      require 'produce'
      produce_options = {
        username: self.user,
        team_id: self.adp_team_id,
        itc_team_id: self.itc_team_id,
        platform: "ios",
        app_identifier: self.app_identifier
      }
      if mode == :adp
        produce_options[:skip_itc] = true
      else
        produce_options[:skip_devcenter] = true
      end

      # The retrying system allows people to correct invalid inputs
      # e.g. the app's name is already taken
      loop do
        # Creating config in the loop so user will be reprompted
        # for app name if app name is taken or too long
        Produce.config = FastlaneCore::Configuration.create(
          Produce::Options.available_options,
          produce_options
        )

        begin
          Produce::Manager.start_producing
          UI.success("✅  Successfully created app")
          return # success
        rescue => ex
          # show the user facing error, and inform them of what went wrong
          if ex.kind_of?(Spaceship::Client::BasicPreferredInfoError) || ex.kind_of?(Spaceship::Client::UnexpectedResponse)
            UI.error(ex.preferred_error_info)
          else
            UI.error(ex.to_s)
          end
          UI.error(ex.backtrace.join("\n")) if FastlaneCore::Globals.verbose?
          UI.important("It looks like something went wrong when we tried to create your app on the Apple Developer Portal")
          unless UI.confirm("Would you like to try again (y)? If you enter (n), fastlane will fall back to the manual setup")
            raise ex
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
