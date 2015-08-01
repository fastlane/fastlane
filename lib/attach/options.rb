require "fastlane_core"
require "credentials_manager"

module Attach
  class Options
    def self.available_options
      workspace = Dir["./*.xcworkspace"]
      if workspace.count > 1
        puts "Select Workspace: "
        workspace = choose *workspace
      else
        workspace = workspace.first # this will result in nil if no files were found
      end

      project = Dir["./*.xcodeproj"]
      if project.count > 1
        puts "Select Project: "
        project = choose *project
      else
        project = project.first # this will result in nil if no files were found
      end

      @options ||= [
        FastlaneCore::ConfigItem.new(key: :workspace,
                                     short_option: "-w",
                                     # env_name: "PILOT_USERNAME",
                                     optional: true,
                                     description: "Path the workspace file",
                                     default_value: workspace,
                                     verify_block: proc do |value|
                                       raise "Workspace file not found at path '#{File.expand_path(value)}'" unless File.exist?(value.to_s)
                                       raise "Workspace file invalid" unless File.directory?(value.to_s)
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

    # This is needed as these are more complex default values
    # Returns the finished config object
    def self.set_additional_default_values
      config = Attach.config

      if config[:workspace].to_s.length == 0 and config[:project].to_s.length == 0
        require 'pry'; binding.pry
      end

      if config[:workspace].to_s.length > 0 and config[:project].to_s.lenght > 0
        require 'pry'; binding.pry # invalid call here
      end

      if config[:scheme].to_s.length == 0
        proj_schemes = Attach.project.schemes
        if proj_schemes.count == 1
          config[:scheme] = proj_schemes.last
        elsif proj_schemes.count > 1
          puts "Select Scheme: "
          config[:scheme] = choose *proj_schemes
        else
          raise "Couldn't find any schemes in this project".red
        end
      end

      return config
    end
  end
end
