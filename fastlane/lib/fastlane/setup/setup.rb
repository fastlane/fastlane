require "tty-spinner"

module Fastlane
  class Setup
    # Is the current `setup` using a swift based configuration file
    attr_accessor :is_swift_fastfile

    # :ios or :android # TODO: maybe more in the future (react-native?)
    attr_accessor :platform

    # Path to the xcodeproj or xcworkspace
    attr_accessor :project_path

    # Used for :manual sometimes
    attr_accessor :preferred_setup_method

    # remember if there were multiple projects
    # if so, we set it as part of the Fastfile
    attr_accessor :had_multiple_projects_to_choose_from

    # The current content of the generated Fastfile
    attr_accessor :fastfile_content

    # Appfile
    attr_accessor :appfile_content

    # For iOS projects that's the Apple ID email
    attr_accessor :user

    # This is the lane that we tell the user to run to try the new fastlane setup
    # This needs to be setup by each setup
    attr_accessor :lane_to_mention

    # Start the setup process
    # rubocop:disable Metrics/BlockNesting
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

      spinner = TTY::Spinner.new("[:spinner] Looking for iOS and Android projects in current directory...", format: :dots)
      spinner.auto_spin

      ios_projects = Dir["**/*.xcodeproj"] + Dir["**/*.xcworkspace"]
      android_projects = Dir["**/*.gradle"]

      spinner.success

      FastlaneCore::FastlaneFolder.create_folder!

      if ios_projects.count > 0 && android_projects.count > 0
        UI.message("It seems like you have both iOS and Android projects in the current directory")
        # TODO: Implement here
      elsif ios_projects.count > 0
        current_directory = ios_projects.find_all do |current_project_path|
          current_project_path.split(File::Separator).count == 1
        end
        chosen_project = nil
        had_multiple_projects_to_choose_from = false

        if current_directory.count == 1
          chosen_project = current_directory.first
        elsif current_directory.count > 1
          if current_directory.count == 2
            # This is a common case (e.g. with CocoaPods), where the project has an xcodeproj and an xcworkspace file
            extensions = [File.extname(current_directory[0]), File.extname(current_directory[1])]
            if extensions.sort == [".xcodeproj", ".xcworkspace"].sort
              # Yep, that's this kind of setup
              chosen_project = current_directory.find { |d| d.end_with?(".xcworkspace") }
            end
          end
          chosen_project ||= UI.select("Multiple iOS projects found in current directory", current_directory)
          had_multiple_projects_to_choose_from = true
        else
          UI.error("Looks like there is no iOS project in the current directory, but inside a sub-directory instead")
          UI.error("Please use `cd` into the subfolder of the location of your Xcode project")
          UI.user_error!("Please `cd` into the subfolder of your Xcode project and run `fastlane init` again")
        end

        if chosen_project == "Pods.xcodeproj"
          unless UI.confirm("Found '#{chosen_project}', which usually isn't a valid Xcode project. Make sure to switch to the directory containing your iOS Xcode project. Do you still want to continue?")
            UI.user_error!("Make sure to `cd` into the right directory and then use `fastlane init` again")
          end
        end
        UI.message("Detected iOS/Mac project in current directory: '#{chosen_project}'")

        SetupIos.new(
          is_swift_fastfile: is_swift_fastfile,
          user: user,
          project_path: chosen_project,
          had_multiple_projects_to_choose_from: had_multiple_projects_to_choose_from
        ).setup_ios
      elsif android_projects.count > 0
        UI.message("Detected Android project in current directory...")
        SetupAndroid.new.setup_android
      else
        UI.error("No iOS or Android projects found in current directory '#{Dir.pwd}'")
        UI.error("Make sure to `cd` into a directory containing your iOS or Android app")
        if UI.confirm("Do you still want to setup a manual fastlane config in the current directory?")
          SetupIos.new(
            is_swift_fastfile: is_swift_fastfile,
            user: user,
            project_path: chosen_project,
            had_multiple_projects_to_choose_from: had_multiple_projects_to_choose_from,
            preferred_setup_method: :ios_manual
          ).setup_ios
        else
          UI.user_error!("Make sure to `cd` into the right directory and then use `fastlane init` again")
        end
      end
    end
    # rubocop:enable Metrics/BlockNesting

    def initialize(is_swift_fastfile: nil, user: nil, project_path: nil, had_multiple_projects_to_choose_from: nil, preferred_setup_method: nil)
      self.is_swift_fastfile = is_swift_fastfile
      self.user = user
      self.project_path = project_path
      self.had_multiple_projects_to_choose_from = had_multiple_projects_to_choose_from
      self.preferred_setup_method = preferred_setup_method
    end

    # Helpers
    def welcome_to_fastlane
      UI.header("Welcome to fastlane 🚀")
      UI.message("fastlane can help you with all kinds of mobile app automation")
      UI.message("We recommend getting started with one piece and then gradually automate more and more over time")
    end

    # Append a lane to the current Fastfile template we're generating
    def append_lane(lane)
      lane.compact! # remove nil values

      new_lines = "\n\n"
      if self.is_swift_fastfile
        new_lines = "" unless self.fastfile_content.include?("lane() {") # the first lane we don't want new lines
        self.fastfile_content.gsub!("[[LANES]]", "#{new_lines}\t#{lane.join("\n\t")}[[LANES]]")
      else
        new_lines = "" unless self.fastfile_content.include?("lane :") # the first lane we don't want new lines
        self.fastfile_content.gsub!("[[LANES]]", "#{new_lines}  #{lane.join("\n  ")}[[LANES]]")
      end
    end

    # Append a team to the Appfile
    def append_team(team)
      self.appfile_content.gsub!("[[TEAMS]]", "#{team}\n[[TEAMS]]")
    end

    def write_fastfile!
      # Write the Fastfile
      fastfile_file_name = "Fastfile"
      fastfile_file_name += ".swift" if self.is_swift_fastfile

      fastfile_path = File.join(FastlaneCore::FastlaneFolder.path, fastfile_file_name)
      self.fastfile_content.gsub!("[[LANES]]", "") # since we always keep it until writing out
      File.write(fastfile_path, self.fastfile_content) # remove trailing spaces before platform ends

      appfile_file_name = "Appfile"
      appfile_file_name += ".swift" if self.is_swift_fastfile
      appfile_path = File.join(FastlaneCore::FastlaneFolder.path, appfile_file_name)
      self.appfile_content.gsub!("[[TEAMS]]", "")

      File.write(appfile_path, self.appfile_content)

      UI.header("✅  Successfully generated fastlane configuration")
      UI.message("Generated Fastfile at path `#{fastfile_path}`")
      UI.message("Generated Appfile at path `#{appfile_path}`")

      UI.message("Please check the newly generated configuration files into git together with your project")
      UI.message("This way, everyone in your team can easily use the fastlane setup")
      continue_with_enter
    end

    def finish_up
      write_fastfile!
      setup_swift_support if is_swift_fastfile
      show_analytics_note
      explain_concepts
      suggest_next_steps
    end

    def setup_swift_support
      runner_source_resources = "#{Fastlane::ROOT}/swift/."
      destination_path = File.expand_path('swift', FastlaneCore::FastlaneFolder.path)
      FileUtils.cp_r(runner_source_resources, destination_path)
      UI.success("Copied Swift fastlane runner project to '#{destination_path}'.")

      Fastlane::SwiftLaneManager.first_time_setup
    end

    def fastfile_template_content
      # TODO: Support android
      if self.is_swift_fastfile
        path = "#{Fastlane::ROOT}/lib/assets/DefaultFastfileTemplate.swift"
      else
        path = "#{Fastlane::ROOT}/lib/assets/DefaultFastfileTemplate"
      end

      return File.read(path)
    end

    def appfile_template_content
      if self.platform == :ios
        if self.is_swift_fastfile
          path = "#{Fastlane::ROOT}/lib/assets/AppfileTemplate.swift"
        else
          path = "#{Fastlane::ROOT}/lib/assets/AppfileTemplate"
        end
      else
        path = "#{Fastlane::ROOT}/lib/assets/AppfileTemplateAndroid"
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
        UI.message("📸  Learn more about how to automatically generate localized App Store screenshots:")
        UI.message("\t\thttps://docs.fastlane.tools/getting-started/ios/screenshots/".cyan)
        UI.message("👩‍✈️  Learn more about distribution to beta testing services:")
        UI.message("\t\thttps://docs.fastlane.tools/getting-started/ios/beta-deployment/".cyan)
        UI.message("🚀  Learn more about how to automate the App Store release process:")
        UI.message("\t\thttps://docs.fastlane.tools/getting-started/ios/appstore-deployment/".cyan)
        UI.message("👩‍⚕️  Lern more about how to setup code signing with fastlane")
        UI.message("\t\thttps://docs.fastlane.tools/codesigning/getting-started/".cyan)
      else
        UI.message("📸  Learn more about how to automatically generate localized Google Play screenshots:")
        UI.message("\t\thttps://docs.fastlane.tools/getting-started/android/screenshots/".cyan)
        UI.message("👩‍✈️  Learn more about distribution to beta testing services:")
        UI.message("\t\thttps://docs.fastlane.tools/getting-started/android/beta-deployment/".cyan)
        UI.message("🚀  Learn more about how to automate the Google Play release process:")
        UI.message("\t\thttps://docs.fastlane.tools/getting-started/android/release-deployment/".cyan)
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
require 'fastlane/setup/setup_android'
