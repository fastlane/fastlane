module Fastlane
  class Setup
    # Is the current `setup` using a swift based configuration file
    attr_accessor :is_swift_fastfile

    # :ios or :android # TODO: maybe more in the future (react-native?)
    attr_accessor :platform

    # The current content of the generated Fastfile
    attr_accessor :fastfile_content

    # Start the setup process
    def run(user: nil, is_swift_fastfile: false)
      if FastlaneCore::FastlaneFolder.setup? and !Helper.is_test?
        require 'fastlane/lane_list'
        Fastlane::LaneList.output(FastlaneCore::FastlaneFolder.fastfile_path)
        UI.important("------------------")
        UI.important("fastlane is already set up at path `#{FastlaneCore::FastlaneFolder.path}`, see the available lanes above")
        return
      end

      self.is_swift_fastfile = false # TODO: this is just for now

      # TODO: Search subdirectory
      ios_projects = Dir["*.xcodeproj"] + Dir["*.xcworkspace"] # TODO: Search sub-directories also
      android_projects = Dir["*.gradle"]
      # react_native_projects = # TODO, we have code in the old `setup_ios` class

      if ios_projects.count > 0 && android_projects.count > 0
        UI.message("It seems like you have both iOS and Android projects in the current directory")
        # TODO: Implement here
      elsif ios_projects.count > 0
        UI.message("Detected iOS/Mac project in current directory...")
        setup_ios
      elsif android_projects.count > 0
        UI.message("Detected Android project in current directory...")
        # TODO: implement
      end

      # TODO: Implement swift flow
      # Now that we've setup all the things, if we're using Swift, do the first time setup
      # if is_swift_fastfile
      #   Fastlane::SwiftLaneManager.first_time_setup
      # end
    end

    def setup_ios
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
    end

    def ios_app_store
      UI.header("Setting up fastlane for iOS App Store distribution")
    end

    def ios_screenshots
      UI.header("Setting up fastlane to automate iOS screenshots")
    end

    def ios_manual
      UI.header("Setting up fastlane, the manual way")
      append_lane(["lane :custom_lane do",
                   "  # add actions here: https://docs.fastlane.tools/actions",
                   "end"])
      finishing_up
    end

    # Helpers
    def welcome_to_fastlane
      UI.header("Welcome to fastlane 🚀")
      UI.message("fastlane can help you with all kinds of mobile app automation")
      UI.message("We recommend getting started with one piece and then gradually automate more and more over time")
    end

    # Append a lane to the current Fastfile template we're generating
    def append_lane(lane)
      self.fastfile_content.gsub!("[[lanes]]", "#{lane.join("\n")}\n\n[[lanes]]")
    end

    def write_fastfile!
      FastlaneCore::FastlaneFolder.create_folder!

      path = File.join(FastlaneCore::FastlaneFolder.path, 'Fastfile') # TODO: different path for swift
      self.fastfile_content.gsub!("[[lanes]]", "") # since we always keep it until writing out
      File.write(path, self.fastfile_content)
      UI.success("✅  Successfully generated fastlane configuration at `#{path}`")
    end

    def finishing_up
      write_fastfile!
      show_analytics_note
      explain_concepts
      suggest_next_steps
    end

    def fastfile_template_content
      # TODO: Support android
      if self.is_swift_fastfile
        # TODO: Implement & simplify the swift based file also
        path = "#{Fastlane::ROOT}/lib/assets/DefaultFastfileTemplate.swift"
      else
        path = "#{Fastlane::ROOT}/lib/assets/DefaultFastfileTemplate"
      end

      return File.read(path)
    end

    def explain_concepts
      UI.header("fastlane lanes")
      UI.message("fastlane uses a " + "`Fastfile`".yellow + " to store the automation configuration")
      UI.message("Within that, you'll see different " + "lanes".yellow + ", each is there to automate a different process")
      UI.message("This way, you can easily use fastlane to solve different tasks")
      UI.message("like screenshots, code signing or pushing new releases")

      UI.header("How to customize your Fastfile")
      UI.message("Use a code editor of your choice to open the newly created Fastfile and take a look")
      UI.message("You can now edit the available lanes and actions to customize the setup to fit your needs")
      UI.message("To get a list of all the available actions, open " + "https://docs.fastlane.tools/actions".cyan)
    end

    def suggest_next_steps
      UI.header("Where to go from here?")
      UI.message("👩‍✈️  Learn more about distribution to beta testing services:")
      UI.message("\t\thttps://docs.fastlane.tools/getting-started/ios/beta-deployment/".cyan)
      UI.message("🚀  Learn more about how to automate the App Store release process:")
      UI.message("\t\thttps://docs.fastlane.tools/getting-started/ios/appstore-deployment/".cyan)
      UI.message("📸  Learn more about how to automatically generate localized App Store screenshots:")
      UI.message("\t\thttps://docs.fastlane.tools/getting-started/ios/screenshots/".cyan)
    end

    def show_analytics_note
      UI.message("fastlane will collect the number of errors for each action to detect integration issues")
      UI.message("No sensitive/private information will be uploaded, more information: " + "https://docs.fastlane.tools/#metrics".cyan)
    end
  end
end
