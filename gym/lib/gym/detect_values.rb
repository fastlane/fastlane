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
      detect_provisioning_profile

      # Go into the project's folder, as there might be a Gymfile there
      Dir.chdir(File.expand_path("..", Gym.project.path)) do
        config.load_configuration_file(Gym.gymfile_name)
      end

      config[:use_legacy_build_api] = true if Xcode.pre_7?

      if config[:use_legacy_build_api]
        UI.deprecated("the use_legacy_build_api option is deprecated")
        UI.deprecated("it should not be used anymore - e.g.: if you use app-extensions")
      end

      detect_scheme
      detect_platform # we can only do that *after* we have the scheme
      detect_configuration
      detect_toolchain

      config[:output_name] ||= Gym.project.app_name

      return config
    end

    # Helper Methods

    def self.detect_provisioning_profile
      if Gym.config[:provisioning_profile_path].nil?
        return unless Gym.config[:use_legacy_build_api] # we only want to auto-detect the profile when using the legacy build API

        Dir.chdir(File.expand_path("..", Gym.project.path)) do
          profiles = Dir["*.mobileprovision"]
          if profiles.count == 1
            profile = File.expand_path(profiles.last)
          elsif profiles.count > 1
            UI.message "Found more than one provisioning profile in the project directory:"
            profile = choose(*profiles)
          end

          Gym.config[:provisioning_profile_path] = profile
        end
      end

      if Gym.config[:provisioning_profile_path]
        FastlaneCore::ProvisioningProfile.install(Gym.config[:provisioning_profile_path])
      end
    end

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
