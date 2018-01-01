module Fastlane
  class Setup
    # Is the current `setup` using a swift based configuration file
    attr_accessor :is_swift_fastfile

    # :ios or :android # TODO: maybe more in the future (react-native?)
    attr_accessor :platform

    # The current content of the generated Fastfile
    attr_accessor :fastfile_content

    # For iOS projects that's the Apple ID email
    attr_accessor :user

    # This is the lane that we tell the user to run to try the new fastlane setup
    # This needs to be setup by each setup
    attr_accessor :lane_to_mention

    # Start the setup process
    def self.start(user: nil, is_swift_fastfile: false)
      if FastlaneCore::FastlaneFolder.setup? and !Helper.is_test?
        require 'fastlane/lane_list'
        Fastlane::LaneList.output(FastlaneCore::FastlaneFolder.fastfile_path)
        UI.important("------------------")
        UI.important("fastlane is already set up at path `#{FastlaneCore::FastlaneFolder.path}`, see the available lanes above")
        return
      end

      # this is used by e.g. configuration.rb to not show warnings when running produce
      ENV["FASTLANE_ONBOARDING_IN_PROCESS"] = 1.to_s

      is_swift_fastfile = false # TODO: this is just for now

      # TODO: Search subdirectory
      ios_projects = Dir["*.xcodeproj"] + Dir["*.xcworkspace"] # TODO: Search sub-directories also
      android_projects = Dir["*.gradle"]
      # react_native_projects = # TODO, we have code in the old `setup_ios` class

      if ios_projects.count > 0 && android_projects.count > 0
        UI.message("It seems like you have both iOS and Android projects in the current directory")
        # TODO: Implement here
      elsif ios_projects.count > 0
        UI.message("Detected iOS/Mac project in current directory...")
        SetupIos.new(is_swift_fastfile: is_swift_fastfile, user: user).setup_ios
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

    def initialize(is_swift_fastfile: nil, user: nil)
      self.is_swift_fastfile = is_swift_fastfile
      self.user = user
    end

    # Helpers
    def welcome_to_fastlane
      UI.header("Welcome to fastlane 🚀")
      UI.message("fastlane can help you with all kinds of mobile app automation")
      UI.message("We recommend getting started with one piece and then gradually automate more and more over time")
    end

    # Append a lane to the current Fastfile template we're generating
    def append_lane(lane)
      self.fastfile_content.gsub!("[[lanes]]", "  #{lane.join("\n  ")}\n\n[[lanes]]")
    end

    def write_fastfile!
      FastlaneCore::FastlaneFolder.create_folder!

      path = File.join(FastlaneCore::FastlaneFolder.path, 'Fastfile') # TODO: different path for swift
      self.fastfile_content.gsub!("[[lanes]]", "") # since we always keep it until writing out
      File.write(path, self.fastfile_content) # remove trailing spaces before platform ends
      UI.header("✅  Successfully generated fastlane configuration")
      UI.message("Generated Fastfile at path `#{path}`")
      # UI.message("Generated Appfile at path `#{appfile_path}`") # TODO: implement Appfile
      continue_with_enter
    end

    def finish_up
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
      continue_with_enter

      UI.header("How to customize your Fastfile")
      UI.message("Use a code editor of your choice to open the newly created Fastfile and take a look")
      UI.message("You can now edit the available lanes and actions to customize the setup to fit your needs")
      UI.message("To get a list of all the available actions, open " + "https://docs.fastlane.tools/actions".cyan)
      continue_with_enter
    end

    def continue_with_enter
      UI.input("Continue by pressing Enter ⏎")
    end

    def suggest_next_steps
      UI.header("Where to go from here?")
      if self.platform == :ios
        UI.message("👩‍✈️  Learn more about distribution to beta testing services:")
        UI.message("\t\thttps://docs.fastlane.tools/getting-started/ios/beta-deployment/".cyan)
        UI.message("🚀  Learn more about how to automate the App Store release process:")
        UI.message("\t\thttps://docs.fastlane.tools/getting-started/ios/appstore-deployment/".cyan)
        UI.message("📸  Learn more about how to automatically generate localized App Store screenshots:")
        UI.message("\t\thttps://docs.fastlane.tools/getting-started/ios/screenshots/".cyan)
        UI.message("👩‍⚕️  Lern more about how to setup code signing with fastlane")
        UI.message("\t\thttps://docs.fastlane.tools/codesigning/getting-started/".cyan)
      else
        UI.user_error!("not implemented yet")
      end

      # we crash here, so that this never happens when a new setup method is added
      UI.user_error!("No `lane_to_mention` provided by setup method") if self.lane_to_mention.to_s.length == 0
      UI.message("")
      UI.message("To try your new fastlane setup, just enter and run")
      UI.command("fastlane #{self.lane_to_mention}")
    end

    def show_analytics_note
      UI.message("fastlane will collect the number of errors for each action to detect integration issues")
      UI.message("No sensitive/private information will be uploaded, more information: " + "https://docs.fastlane.tools/#metrics".cyan)
    end
  end
end

require 'fastlane/setup/setup_ios'
