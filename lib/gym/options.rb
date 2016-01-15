require "fastlane_core"
require "credentials_manager"

module Gym
  class Options
    def self.available_options
      return @options if @options

      @options = plain_options
    end

    def self.plain_options
      [
        FastlaneCore::ConfigItem.new(key: :workspace,
                                     short_option: "-w",
                                     env_name: "GYM_WORKSPACE",
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
                                     env_name: "GYM_PROJECT",
                                     description: "Path the project file",
                                     verify_block: proc do |value|
                                       v = File.expand_path(value.to_s)
                                       raise "Project file not found at path '#{v}'".red unless File.exist?(v)
                                       raise "Project file invalid".red unless File.directory?(v)
                                       raise "Project file is not a project file, must end with .xcodeproj".red unless v.include?(".xcodeproj")
                                     end),
        FastlaneCore::ConfigItem.new(key: :scheme,
                                     short_option: "-s",
                                     optional: true,
                                     env_name: "GYM_SCHEME",
                                     description: "The project's scheme. Make sure it's marked as `Shared`"),
        FastlaneCore::ConfigItem.new(key: :clean,
                                     short_option: "-c",
                                     env_name: "GYM_CLEAN",
                                     description: "Should the project be cleaned before building it?",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :output_directory,
                                     short_option: "-o",
                                     env_name: "GYM_OUTPUT_DIRECTORY",
                                     description: "The directory in which the ipa file should be stored in",
                                     default_value: "."),
        FastlaneCore::ConfigItem.new(key: :output_name,
                                     short_option: "-n",
                                     env_name: "GYM_OUTPUT_NAME",
                                     description: "The name of the resulting ipa file",
                                     optional: true,
                                     verify_block: proc do |value|
                                       value.gsub!(".ipa", "")
                                     end),
        FastlaneCore::ConfigItem.new(key: :configuration,
                                     short_option: "-q",
                                     env_name: "GYM_CONFIGURATION",
                                     description: "The configuration to use when building the app. Defaults to 'Release'",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :silent,
                                     short_option: "-a",
                                     env_name: "GYM_SILENT",
                                     description: "Hide all information that's not necessary while building",
                                     default_value: false,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :codesigning_identity,
                                     short_option: "-i",
                                     env_name: "GYM_CODE_SIGNING_IDENTITY",
                                     description: "The name of the code signing identity to use. It has to match the name exactly. e.g. 'iPhone Distribution: SunApps GmbH'",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :include_symbols,
                                     short_option: "-m",
                                     env_name: "GYM_INCLUDE_SYMBOLS",
                                     description: "Should the ipa file include symbols?",
                                     default_value: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :include_bitcode,
                                     short_option: "-z",
                                     env_name: "GYM_INCLUDE_BITCODE",
                                     description: "Should the ipa include bitcode?",
                                     default_value: false,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :use_legacy_build_api,
                                     env_name: "GYM_USE_LEGACY_BUILD_API",
                                     description: "Don't use the new API because of https://openradar.appspot.com/radar?id=4952000420642816",
                                     default_value: false,
                                     is_string: false,
                                     verify_block: proc do |value|
                                       if value
                                         UI.important "Using legacy build system - waiting for radar to be fixed: https://openradar.appspot.com/radar?id=4952000420642816"
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :export_method,
                                     short_option: "-j",
                                     env_name: "GYM_EXPORT_METHOD",
                                     description: "How should gym export the archive?",
                                     is_string: true,
                                     optional: true,
                                     verify_block: proc do |value|
                                       av = %w(app-store ad-hoc package enterprise development developer-id)
                                       raise "Unsupported export_method, must be: #{av}" unless av.include?(value)
                                     end),

        # Very optional
        FastlaneCore::ConfigItem.new(key: :archive_path,
                                     short_option: "-b",
                                     env_name: "GYM_ARCHIVE_PATH",
                                     description: "The directory in which the archive file should be stored in",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :derived_data_path,
                                     short_option: "-f",
                                     env_name: "GYM_DERIVED_DATA_PATH",
                                     description: "The directory where build products and other derived data will go",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :result_bundle,
                                     short_option: "-u",
                                     env_name: "GYM_RESULT_BUNDLE",
                                     is_string: false,
                                     description: "Produce the result bundle describing what occurred will be placed",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :buildlog_path,
                                     short_option: "-l",
                                     env_name: "GYM_BUILDLOG_PATH",
                                     description: "The directory where to store the build log",
                                     default_value: "~/Library/Logs/gym"),
        FastlaneCore::ConfigItem.new(key: :sdk,
                                     short_option: "-k",
                                     env_name: "GYM_SDK",
                                     description: "The SDK that should be used for building the application",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :provisioning_profile_path,
                                     short_option: "-e",
                                     env_name: "GYM_PROVISIONING_PROFILE_PATH",
                                     description: "The path to the provisioning profile (optional)",
                                     optional: true,
                                     verify_block: proc do |value|
                                       raise "Provisioning profile not found at path '#{File.expand_path(value)}'".red unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :destination,
                                     short_option: "-d",
                                     env_name: "GYM_DESTINATION",
                                     description: "Use a custom destination for building the app",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :export_team_id,
                                     short_option: "-g",
                                     env_name: "GYM_EXPORT_TEAM_ID",
                                     description: "Optional: Sometimes you need to specify a team id when exporting the ipa file",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :xcargs,
                                     short_option: "-x",
                                     env_name: "GYM_XCARGS",
                                     description: "Pass additional arguments to xcodebuild. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS=\"-ObjC -lstdc++\"",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :xcconfig,
                                     short_option: "-y",
                                     env_name: "GYM_XCCONFIG",
                                     description: "Use an extra XCCONFIG file to build your app",
                                     optional: true,
                                     verify_block: proc do |value|
                                       raise "File not found at path '#{File.expand_path(value)}'".red unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :suppress_xcode_output,
                                     short_option: "-r",
                                     env_name: "SUPPRESS_OUTPUT",
                                     description: "Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path",
                                     optional: true,
                                     is_string: false
                                    )
      ]
    end
  end
end
