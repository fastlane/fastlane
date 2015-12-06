require 'fastlane_core'

module Snapshot
  class Options
    def self.available_options
      output_directory = (File.directory?("fastlane") ? "fastlane/screenshots" : "screenshots")

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
                                     optional: true,
                                     verify_block: proc do |value|
                                       raise "Devices must be an array" unless value.kind_of?(Array)
                                       available = FastlaneCore::Simulator.all
                                       value.each do |current|
                                         unless available.any? { |d| d.name.strip == current.strip }
                                           raise "Device '#{current}' not in list of available simulators '#{available.join(', ')}'".red
                                         end
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :languages,
                                     description: "A list of languages which should be used",
                                     is_string: false,
                                     default_value: [
                                       'en-US'
                                     ]),
        FastlaneCore::ConfigItem.new(key: :launch_arguments,
                                     env_name: 'SNAPSHOT_LAUNCH_ARGUMENTS',
                                     description: "A list of launch arguments which should be used",
                                     is_string: false,
                                     default_value: [
                                       ''
                                     ]),
        FastlaneCore::ConfigItem.new(key: :output_directory,
                                     short_option: "-o",
                                     env_name: "SNAPSHOT_OUTPUT_DIRECTORY",
                                     description: "The directory where to store the screenshots",
                                     default_value: output_directory),
        FastlaneCore::ConfigItem.new(key: :ios_version,
                                     description: "By default, the latest version should be used automatically. If you want to change it, do it here",
                                     default_value: Snapshot::LatestIosVersion.version),
        FastlaneCore::ConfigItem.new(key: :stop_after_first_error,
                                     env_name: 'SNAPSHOT_BREAK_ON_FIRST_ERROR',
                                     description: "Should snapshot stop immediately after one of the tests failed on one device?",
                                     default_value: false,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :skip_open_summary,
                                     env_name: 'SNAPSHOT_SKIP_OPEN_SUMMARY',
                                     description: "Don't open the HTML summary after running `snapshot`",
                                     default_value: false,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :clear_previous_screenshots,
                                     env_name: 'SNAPSHOT_CLEAR_PREVIOUS_SCREENSHOTS',
                                     description: "Enabling this option will automatically clear previously generated screenshots before running snapshot",
                                     default_value: false,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :uninstall_app,
                                     env_name: 'SNAPSHOT_UNINSTALL_APP',
                                     description: "Enabling this option will automatically uninstall application before running snapshot",
                                     default_value: false,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     env_name: 'SNAPSHOT_APP_IDENTIFIER',
                                     description: "The bundle identifier of the app to uninstall",
                                     default_value: ENV["SNAPSHOT_APP_IDENTITIFER"] || CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),

        # Everything around building
        FastlaneCore::ConfigItem.new(key: :buildlog_path,
                                     short_option: "-l",
                                     env_name: "SNAPSHOT_BUILDLOG_PATH",
                                     description: "The directory where to store the build log",
                                     default_value: "~/Library/Logs/snapshot"),
        FastlaneCore::ConfigItem.new(key: :clean,
                                     short_option: "-c",
                                     env_name: "SNAPSHOT_CLEAN",
                                     description: "Should the project be cleaned before building it?",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :configuration,
                                     short_option: "-q",
                                     env_name: "SNAPSHOT_CONFIGURATION",
                                     description: "The configuration to use when building the app. Defaults to 'Release'",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :sdk,
                                     short_option: "-k",
                                     env_name: "SNAPSHOT_SDK",
                                     description: "The SDK that should be used for building the application",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :scheme,
                                     short_option: "-s",
                                     env_name: 'SNAPSHOT_SCHEME',
                                     description: "The scheme you want to use, this must be the scheme for the UI Tests",
                                     optional: true) # optional true because we offer a picker to the user
      ]
    end
  end
end
