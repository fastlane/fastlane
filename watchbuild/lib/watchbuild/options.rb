require 'fastlane_core'
require 'credentials_manager'

module WatchBuild
  class Options
    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "FASTLANE_USER",
                                     description: "Your Apple ID Username",
                                     default_value: user),
        FastlaneCore::ConfigItem.new(key: :sample_only_once,
                                     description: "Only check for the build once, instead of waiting for it to process",
                                     is_string: false,
                                     default_value: false)
      ]
    end
  end
end
