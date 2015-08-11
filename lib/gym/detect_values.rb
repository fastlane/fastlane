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

      if Gym.config[:provisioning_profile_path].to_s.length == 0 and !Helper.is_test?
        [
          "Could not automatically find provisioning profile to use",
          "Please either put the provisioning profile in the project directory",
          "or pass the path via the `provisioning_profile_path` option",
          "Additionally you can pass the name of the profile using",
          "the `provisioning_profile_name` option.",
          "If you run `sigh` before `gym` you get all that for free."
        ].each { |a| Helper.log.error a.red }

        raise "No provisioning profile passed"
      end

      if Gym.config[:provisioning_profile_path]
        FastlaneCore::ProvisioningProfile.install(Gym.config[:provisioning_profile_path])
        data = FastlaneCore::ProvisioningProfile.parse(Gym.config[:provisioning_profile_path])

        if data['Name']
          Helper.log.info "Using provisioning profile with name '#{data['Name']}'...".green if $verbose
          Gym.config[:provisioning_profile_name] = data['Name']
        end
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
      if config[:scheme].to_s.length > 0
        # Verify the scheme is available
        unless Gym.project.schemes.include?(config[:scheme].to_s)
          Helper.log.error "Couldn't find specified scheme '#{config[:scheme]}'.".red
          config[:scheme] = nil
        end
      end

      if config[:scheme].to_s.length == 0
        proj_schemes = Gym.project.schemes
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
          raise "Couldn't find any schemes in this project".red
        end
      end
    end
  end
end
