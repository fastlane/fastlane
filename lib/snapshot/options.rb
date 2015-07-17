require 'fastlane_core'

module Snapshot
  class Options
    def self.available_options
      @@options ||= [
        FastlaneCore::ConfigItem.new(key: :devices,
                                     description: "A list of devices you want to take the screenshots from",
                                     is_string: false,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :languages,
                                     description: "A list of languages which should be used",
                                     is_string: false,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :ios_version,
                                     description: "By default, the latest version should be used automatically. If you want to change it, do it here",
                                     default_value: Snapshot::LatestIosVersion.version),
        FastlaneCore::ConfigItem.new(key: :scheme,
                                     env_name: 'SNAPSHOT_SCHEME',
                                     description: "The scheme you want to use, this must be the scheme for the UI Tests",
                                     default_value: Snapshot::LatestIosVersion.version,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :project_path,
                                     env_name: 'SNAPSHOT_PROJECT_PATH',
                                     description: "Where is your project (or workspace)? Provide the full path here",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :screenshots_path,
                                     env_name: 'SNAPSHOT_PROJECT_PATH',
                                     description: "The path, in which the screenshots should be stored",
                                     default_value: './screenshots')
      ]
    end
  end
end
