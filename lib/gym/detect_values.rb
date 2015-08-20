module Gym
  # This class detects all kinds of default values
  class DetectValues
    # This is needed as these are more complex default values
    # Returns the finished config object
    def self.set_additional_default_values
      config = Gym.config

      detect_projects

      if config[:workspace].to_s.length > 0 and config[:project].to_s.length > 0
        raise "You can only pass either a workspace or a project path, not both".red
      end

      if config[:workspace].to_s.length == 0 and config[:project].to_s.length == 0
        raise "No project/workspace found in the current directory.".red
      end

      Gym.project = Project.new(config)
      detect_provisioning_profile

      # Go into the project's folder
      Dir.chdir(File.expand_path("..", Gym.project.path)) do
        config.load_configuration_file(Gym.gymfile_name)
      end

      detect_scheme
      detect_platform # we can only do that *after* we have the scheme
      detect_configuration

      config[:output_name] ||= Gym.project.app_name

      return config
    end

    # Helper Methods

    def self.detect_provisioning_profile
      unless Gym.config[:provisioning_profile_path]
        Dir.chdir(File.expand_path("..", Gym.project.path)) do
          profiles = Dir["*.mobileprovision"]
          if profiles.count == 1
            profile = File.expand_path(profiles.last)
          elsif profiles.count > 1
            puts "Found more than one provisioning profile in the project directory:"
            profile = choose(*(profiles))
          end

          Gym.config[:provisioning_profile_path] = profile
        end
      end

      if Gym.config[:provisioning_profile_path]
        FastlaneCore::ProvisioningProfile.install(Gym.config[:provisioning_profile_path])
      end
    end

    def self.detect_projects
      if Gym.config[:workspace].to_s.length == 0
        workspace = Dir["./*.xcworkspace"]
        if workspace.count > 1
          puts "Select Workspace: "
          Gym.config[:workspace] = choose(*(workspace))
        else
          Gym.config[:workspace] = workspace.first # this will result in nil if no files were found
        end
      end

      if Gym.config[:workspace].to_s.length == 0 and Gym.config[:project].to_s.length == 0
        project = Dir["./*.xcodeproj"]
        if project.count > 1
          puts "Select Project: "
          Gym.config[:project] = choose(*(project))
        else
          Gym.config[:project] = project.first # this will result in nil if no files were found
        end
      end
    end

    def self.choose_project
      loop do
        path = ask("Couldn't automatically detect the project file, please provide a path: ".yellow).strip
        if File.directory? path
          if path.end_with? ".xcworkspace"
            config[:workspace] = path
            break
          elsif path.end_with? ".xcodeproj"
            config[:project] = path
            break
          else
            Helper.log.error "Path must end with either .xcworkspace or .xcodeproj"
          end
        else
          Helper.log.error "Couldn't find project at path '#{File.expand_path(path)}'".red
        end
      end
    end

    def self.detect_scheme
      config = Gym.config
      proj_schemes = Gym.project.schemes

      if config[:scheme].to_s.length > 0
        # Verify the scheme is available
        unless proj_schemes.include?(config[:scheme].to_s)
          Helper.log.error "Couldn't find specified scheme '#{config[:scheme]}'.".red
          config[:scheme] = nil
        end
      end

      return if config[:scheme].to_s.length > 0

      if proj_schemes.count == 1
        config[:scheme] = proj_schemes.last
      elsif proj_schemes.count > 1
        if Helper.is_ci?
          Helper.log.error "Multiple schemes found but you haven't specified one.".red
          Helper.log.error "Since this is a CI, please pass one using the `scheme` option".red
          raise "Multiple schemes found".red
        else
          puts "Select Scheme: "
          config[:scheme] = choose(*(proj_schemes))
        end
      else
        Helper.log.error "Couldn't find any schemes in this project, make sure that the scheme is shared if you are using a workspace".red

        raise "No Schemes found".red
      end
    end

    # Is it an iOS device or a Mac?
    def self.detect_platform
      return if Gym.config[:destination]
      platform = Gym.project.build_settings(key: "PLATFORM_DISPLAY_NAME") || "iOS" # either `iOS` or `OS X`

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
          Helper.log.error "Couldn't find specified configuration '#{config[:configuration]}'.".red
          config[:configuration] = nil
        end
      end

      # Usually we want `Release`
      # We prefer `Release` to export the DSYM file as well
      config[:configuration] ||= "Release" if configurations.include?("Release")

      return if config[:configuration].to_s.length > 0

      if configurations.count == 1
        config[:configuration] = configurations.last
      else
        if Helper.is_ci?
          Helper.log.error "Multiple configurations found but you haven't specified one.".red
          Helper.log.error "Since this is a CI, please pass one using the `configuration` option".red
          raise "Multiple configurations found".red
        else
          puts "Select Configuration: "
          config[:configuration] = choose(*(configurations))
        end
      end
    end

  end
end
