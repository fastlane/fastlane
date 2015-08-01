require "fastlane_core"
require "credentials_manager"

module Gym
  class Options
    def self.available_options
      return @options if @options

      workspace = Dir["./*.xcworkspace"]
      if workspace.count > 1
        puts "Select Workspace: "
        workspace = choose(*(workspace))
      else
        workspace = workspace.first # this will result in nil if no files were found
      end

      project = Dir["./*.xcodeproj"]
      if project.count > 1
        puts "Select Project: "
        project = choose(*(project))
      else
        project = project.first # this will result in nil if no files were found
      end

      @options ||= plain_options(project: project, workspace: workspace)
    end

    # This is needed as these are more complex default values
    # Returns the finished config object
    def self.set_additional_default_values
      config = Gym.config

      if config[:workspace].to_s.length == 0 and config[:project].to_s.length == 0
        loop do
          path = ask("Couldn't automatically detect the project file, please provide a path: ".yellow).strip
          if File.directory?path
            if path.end_with?".xcworkspace"
              config[:workspace] = path
              break
            elsif path.end_with?".xcodeproj"
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

      if config[:workspace].to_s.length > 0 and config[:project].to_s.length > 0
        require 'pry'; binding.pry # invalid call here
      end

      Gym.project = Project.new(config)

      if config[:scheme].to_s.length == 0
        proj_schemes = Gym.project.schemes
        if proj_schemes.count == 1
          config[:scheme] = proj_schemes.last
        elsif proj_schemes.count > 1
          puts "Select Scheme: "
          config[:scheme] = choose(*(proj_schemes))
        else
          raise "Couldn't find any schemes in this project".red
        end
      end

      return config
    end

    def self.plain_options(project: nil, workspace: nil)
      [
        FastlaneCore::ConfigItem.new(key: :workspace,
                                     short_option: "-w",
                                     # env_name: "PILOT_USERNAME",
                                     optional: true,
                                     description: "Path the workspace file",
                                     default_value: workspace,
                                     verify_block: proc do |value|
                                       raise "Workspace file not found at path '#{File.expand_path(value)}'" unless File.exist?(value.to_s)
                                       raise "Workspace file invalid" unless File.directory?(value.to_s)
                                       raise "Workspace file is not a workspace, must end with .xcworkspace" unless value.end_with?(".xcworkspace")
                                     end),
        FastlaneCore::ConfigItem.new(key: :project,
                                     short_option: "-p",
                                     optional: true,
                                     # env_name: "PILOT_USERNAME",
                                     description: "Path the project file",
                                     default_value: project,
                                     verify_block: proc do |value|
                                       raise "Project file not found at path '#{File.expand_path(value)}'" unless File.exist?(value.to_s)
                                       raise "Project file invalid" unless File.directory?(value.to_s)
                                       raise "Project file is not a project file, must end with .xcodeproj" unless value.end_with?(".xcodeproj")
                                     end),
        FastlaneCore::ConfigItem.new(key: :scheme,
                                     short_option: "-s",
                                     optional: true,
                                     # env_name: "PILOT_USERNAME",
                                     description: "The project scheme. Make sure it's marked as `Shared`",
                                     verify_block: proc do |value|
                                       raise "Project file not found at path '#{File.expand_path(value)}'" unless File.exist?(value.to_s)
                                       raise "Project file invalid" unless File.directory?(value.to_s)
                                     end),
        FastlaneCore::ConfigItem.new(key: :clean,
                                     short_option: "-c",
                                     # env_name: "PILOT_USERNAME",
                                     description: "Should the project be cleaned before building it?",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :output_directory,
                                     short_option: "-o",
                                     # env_name: "PILOT_USERNAME",
                                     description: "The directory in which the ipa file should be stored in",
                                     default_value: ".",
                                     verify_block: proc do |value|
                                       raise "Directory not found at path '#{File.expand_path(value)}'" unless File.directory?(value)
                                     end)

      ]
    end
  end
end
