require 'fastlane_core'
require 'credentials_manager'

module Deliver
  class Options
    def self.available_options
      @options ||= [
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "DELIVER_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "DELIVER_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :app,
                                     short_option: "-p",
                                     env_name: "DELIVER_APP_ID",
                                     description: "The app ID of the app you want to use/modify",
                                     is_string: false), # don't add any verification here, as it's used to store a spaceship ref
        FastlaneCore::ConfigItem.new(key: :ipa,
                                     short_option: "-i",
                                     env_name: "DELIVER_IPA_PATH",
                                     description: "Path to your ipa file",
                                     default_value: Dir["*.ipa"].first,
                                     verify_block: proc do |value|
                                       raise "Could not find ipa file at path '#{value}'" unless File.exist? value
                                       raise "'#{value}' doesn't seem to be an ipa file" unless value.end_with? ".ipa"
                                     end),
        FastlaneCore::ConfigItem.new(key: :skip_metadata,
                                     description: "Only upload the build - no metadata",
                                     is_string: false,
                                     default_value: false),

        # App Metadata
        FastlaneCore::ConfigItem.new(key: :description,
                                     description: "Metadata: The localised app description",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :name,
                                     description: "Metadata: The localised app name",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :keywords,
                                     description: "Metadata: An array of localised keywords",
                                     optional: true,
                                     is_string: false)
      ]
    end
  end
end
