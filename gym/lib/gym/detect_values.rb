require 'cfpropertylist'
module Gym
  # This class detects all kinds of default values
  class DetectValues
    # This is needed as these are more complex default values
    # Returns the finished config object
    def self.set_additional_default_values
      config = Gym.config

      # First, try loading the Gymfile from the current directory
      config.load_configuration_file(Gym.gymfile_name)

      # Detect the project
      FastlaneCore::Project.detect_projects(config)
      Gym.project = FastlaneCore::Project.new(config)

      detect_selected_provisioning_profiles

      # Go into the project's folder, as there might be a Gymfile there
      Dir.chdir(File.expand_path("..", Gym.project.path)) do
        config.load_configuration_file(Gym.gymfile_name)
      end

      detect_scheme
      detect_platform # we can only do that *after* we have the scheme
      detect_configuration
      detect_toolchain

      config[:output_name] ||= Gym.project.app_name

      config[:build_path] ||= archive_path_from_local_xcode_preferences

      return config
    end

    def self.archive_path_from_local_xcode_preferences
      day = Time.now.strftime("%F") # e.g. 2015-08-07
      archive_path = File.expand_path("~/Library/Developer/Xcode/Archives/#{day}/")

      path = xcode_preference_plist_path
      return archive_path unless File.exist?(path.to_s) # this file only exists when you edit the Xcode preferences to set custom values

      custom_archive_path = xcode_preferences_dictionary(path)['IDECustomDistributionArchivesLocation']
      return archive_path if custom_archive_path.to_s.length == 0

      return File.join(custom_archive_path, day)
    end

    # Helper Methods

    def self.xcode_preference_plist_path
      File.expand_path("~/Library/Preferences/com.apple.dt.Xcode.plist")
    end

    def self.xcode_preferences_dictionary(path)
      CFPropertyList.native_types(CFPropertyList::List.new(file: path).value)
    end

    # Since Xcode 9 you need to provide the explicit mapping of what provisioning profile to use for
    # each target of your app
    # rubocop:disable Style/MultilineBlockChain
    def self.detect_selected_provisioning_profiles
      if Gym.config[:export_options] && Gym.config[:export_options].kind_of?(Hash) && Gym.config[:export_options][:provisioningProfiles]
        return
      end

      require 'xcodeproj'

      provisioning_profile_mapping = {}

      # Find the xcodeproj file, as the information isn't included in the workspace file
      if Gym.project.workspace?
        # We have a reference to the workspace, let's find the xcodeproj file
        # For some reason the `plist` gem can't parse the content file
        # so we'll use a regex to find all group references

        workspace_data_path = File.join(Gym.project.path, "contents.xcworkspacedata")
        workspace_data = File.read(workspace_data_path)
        project_paths = workspace_data.scan(/\"group:(.*)\"/).collect do |current_match|
          # It's a relative path from the workspace file
          File.join(File.expand_path("..", Gym.project.path), current_match.first)
        end.find_all do |current_match|
          !current_match.end_with?("Pods/Pods.xcodeproj")
        end
      else
        project_paths = [Gym.project.path]
      end

      # Because there might be multiple projects inside a workspace
      # we iterate over all of them (except for CocoaPods)
      project_paths.each do |project_path|
        UI.verbose("Parsing project file '#{project_path}' to find selected provisioning profiles")
        begin
          project = Xcodeproj::Project.open(project_path)
          project.targets.each do |target|
            target.build_configuration_list.build_configurations.each do |build_configuration|
              current = build_configuration.build_settings

              bundle_identifier = current["PRODUCT_BUNDLE_IDENTIFIER"]
              provisioning_profile_specifier = current["PROVISIONING_PROFILE_SPECIFIER"]
              next if provisioning_profile_specifier.to_s.length == 0

              provisioning_profile_mapping[bundle_identifier] = provisioning_profile_specifier
            end
          end
        rescue => ex
          # We catch errors here, as we might run into an exception on one included project
          # But maybe the next project actually contains the information we need
          if Helper.xcode_at_least?("9.0")
            UI.error(ex)
            UI.verbose(ex.backtrace.join("\n"))
          end
        end
      end

      return if provisioning_profile_mapping.count == 0

      Gym.config[:export_options] ||= {}
      Gym.config[:export_options][:provisioningProfiles] = provisioning_profile_mapping
      UI.message("Detected provisioning profile mapping: #{provisioning_profile_mapping}")
    rescue => ex
      # We don't want to fail the build if the automatic detection doesn't work
      # especially since the mapping is optional for pre Xcode 9 setups
      if Helper.xcode_at_least?("9.0")
        UI.error("Couldn't automatically detect the provisioning profile mapping")
        UI.error("Since Xcode 9 you need to provide an explicit mapping of what")
        UI.error("provisioning profile to use for each target of your app")
        UI.error(ex)
        UI.verbose(ex.backtrace.join("\n"))
      end
    end
    # rubocop:enable Style/MultilineBlockChain

    def self.detect_scheme
      Gym.project.select_scheme
    end

    def self.min_xcode8?
      Helper.xcode_version.split(".").first.to_i >= 8
    end

    # Is it an iOS device or a Mac?
    def self.detect_platform
      return if Gym.config[:destination]
      platform = if Gym.project.mac?
                   min_xcode8? ? "macOS" : "OS X"
                 elsif Gym.project.tvos?
                   "tvOS"
                 else
                   "iOS"
                 end

      Gym.config[:destination] = "generic/platform=#{platform}"
    end

    # Detects the available configurations (e.g. Debug, Release)
    def self.detect_configuration
      config = Gym.config
      configurations = Gym.project.configurations
      return if configurations.count == 0 # this is an optional value anyway

      if config[:configuration]
        # Verify the configuration is available
        unless configurations.include?(config[:configuration])
          UI.error "Couldn't find specified configuration '#{config[:configuration]}'."
          config[:configuration] = nil
        end
      end
    end

    # The toolchain parameter is used if you don't use the default toolchain of Xcode (e.g. Swift 2.3 with Xcode 8)
    def self.detect_toolchain
      return unless Gym.config[:toolchain]

      # Convert the aliases to the full string to make it easier for the user #justfastlanethings
      if Gym.config[:toolchain].to_s == "swift_2_3"
        Gym.config[:toolchain] = "com.apple.dt.toolchain.Swift_2_3"
      end
    end
  end
end
