require 'fastlane_core'

module Snapshot
  class Options
    def self.available_options
      @@options ||= [
        FastlaneCore::ConfigItem.new(key: :workspace,
                                     short_option: "-w",
                                     env_name: "SNAPSHOT_WORKSPACE",
                                     optional: true,
                                     description: "Path the workspace file",
                                     verify_block: proc do |value|
                                       v = File.expand_path(value.to_s)
                                       raise "Workspace file not found at path '#{v}'".red unless File.exist?(v)
                                       raise "Workspace file invalid".red unless File.directory?(v)
                                       raise "Workspace file is not a workspace, must end with .xcworkspace".red unless v.include?(".xcworkspace")
                                     end),
        FastlaneCore::ConfigItem.new(key: :project,
                                     short_option: "-p",
                                     optional: true,
                                     env_name: "SNAPSHOT_PROJECT",
                                     description: "Path the project file",
                                     verify_block: proc do |value|
                                       v = File.expand_path(value.to_s)
                                       raise "Project file not found at path '#{v}'".red unless File.exist?(v)
                                       raise "Project file invalid".red unless File.directory?(v)
                                       raise "Project file is not a project file, must end with .xcodeproj".red unless v.include?(".xcodeproj")
                                     end),
        FastlaneCore::ConfigItem.new(key: :devices,
                                     description: "A list of devices you want to take the screenshots from",
                                     is_string: false,
                                     optional: true),
                                     # verify_block: Proc.new do |value|
                                     #   raise "Devices must be an array" unless value.kind_of?Array
                                     #   available = Simulators.available_devices(name_only: true)
                                     #   value.each do |current|
                                     #     unless available.include?current
                                     #       raise "Device '#{current}' not in list of avaiable simulators '#{available.join(', ')}'"
                                     #     end
                                     #   end
                                     # end),
        FastlaneCore::ConfigItem.new(key: :languages,
                                     description: "A list of languages which should be used",
                                     is_string: false,
                                     default_value: [
                                      'en-US',
                                      # 'de-DE',
                                     ]),
        FastlaneCore::ConfigItem.new(key: :buildlog_path,
                                     short_option: "-l",
                                     env_name: "SNAPSHOT_BUILDLOG_PATH",
                                     description: "The directory were to store the build log",
                                     default_value: "~/Library/Logs/snapshot"),
        FastlaneCore::ConfigItem.new(key: :configuration,
                                     short_option: "-q",
                                     env_name: "SNAPSHOT_CONFIGURATION",
                                     description: "The configuration to use when building the app. Defaults to 'Release'",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :ios_version,
                                     description: "By default, the latest version should be used automatically. If you want to change it, do it here",
                                     default_value: Snapshot::LatestIosVersion.version),
        FastlaneCore::ConfigItem.new(key: :sdk,
                                     short_option: "-k",
                                     env_name: "SNAPSHOT_SDK",
                                     description: "The SDK that should be used for building the application",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :scheme,
                                     short_option: "-s",
                                     env_name: 'SNAPSHOT_SCHEME',
                                     description: "The scheme you want to use, this must be the scheme for the UI Tests",
                                     optional: true), # optional true because we offer a picker to the user
        FastlaneCore::ConfigItem.new(key: :screenshots_path,
                                     env_name: 'SNAPSHOT_PROJECT_PATH',
                                     description: "The path, in which the screenshots should be stored",
                                     default_value: './screenshots'),
        FastlaneCore::ConfigItem.new(key: :html_title,
                                     env_name: 'SNAPSHOT_HTML_TITLE',
                                     description: "The title that is shown on the the browser window in the HTML summary",
                                     default_value: 'KrauseFx/snapshot'),
        FastlaneCore::ConfigItem.new(key: :custom_args,
                                     env_name: 'SNAPSHOT_CUSTOM_ARGS',
                                     description: "TODO",
                                     default_value: ''),
        FastlaneCore::ConfigItem.new(key: :custom_build_args,
                                     env_name: 'SNAPSHOT_CUSTOM_BUILD_ARGS',
                                     description: "TODO",
                                     default_value: 'KrauseFx/snapshot'),
      ]
    end

    # This is needed as these are more complex default values
    def self.set_additional_default_values
      config = Snapshot.config

      detect_projects

      Snapshot.project = FastlaneCore::Project.new(config)
      Snapshot.project.select_scheme

      # Go into the project's folder
      Dir.chdir(File.expand_path("..", Snapshot.project.path)) do
        config.load_configuration_file(Snapshot.snapfile_name)
      end

      # Devices
      unless config[:devices]
        value = Simulator.all
        # Now, we get multiple iPads, but we only need an iPad Air
        # [
        #  "iPad 2",
        #  "iPad Air",
        #  "iPad Air 2",
        #  "iPad Retina"
        # ]
        # value.delete_if { |a| a.include?("iPad") and a != "iPad Air" }
        config[:devices] = value.collect { |d| d }
      end
    end

    def self.detect_projects
      if Snapshot.config[:workspace].to_s.length == 0
        workspace = Dir["./*.xcworkspace"]
        if workspace.count > 1
          puts "Select Workspace: "
          Snapshot.config[:workspace] = choose(*(workspace))
        else
          Snapshot.config[:workspace] = workspace.first # this will result in nil if no files were found
        end
      end

      if Snapshot.config[:workspace].to_s.length == 0 and Snapshot.config[:project].to_s.length == 0
        project = Dir["./*.xcodeproj"]
        if project.count > 1
          puts "Select Project: "
          Snapshot.config[:project] = choose(*(project))
        else
          Snapshot.config[:project] = project.first # this will result in nil if no files were found
        end
      end
    end
  end
end
