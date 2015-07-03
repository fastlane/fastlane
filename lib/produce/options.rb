require 'fastlane_core'
require 'credentials_manager'

module Produce
  class Options
    def self.available_options
      @@options ||= [
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "PRODUCE_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id),
                                     verify_block: Proc.new do |value|
                                       CredentialsManager::PasswordManager.shared_manager(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :bundle_identifier,
                                     env_name: "PRODUCE_APP_IDENTIFIER",
                                     description: "App Identifier (Bundle ID, e.g. com.krausefx.app)",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :bundle_identifier_suffix,
                                     env_name: "PRODUCE_APP_IDENTIFIER_SUFFIX",
                                     description: "App Identifier Suffix (Ignored if App Identifier does not ends with .*)",
                                     default_value: ""),
        FastlaneCore::ConfigItem.new(key: :app_name,
                                     env_name: "PRODUCE_APP_IDENTIFIER",
                                     description: "App Name"),
        FastlaneCore::ConfigItem.new(key: :version,
                                     env_name: "PRODUCE_VERSION",
                                     description: "Initial version number (e.g. '1.0')"),
        FastlaneCore::ConfigItem.new(key: :sku,
                                     env_name: "PRODUCE_SKU",
                                     description: "SKU Number (e.g. '1234')",
                                     default_value: Time.now.to_i.to_s),
        FastlaneCore::ConfigItem.new(key: :primary_language,
                                     env_name: "PRODUCE_LANGUAGE",
                                     description: "Primary Language (e.g. 'English', 'German')",
                                     verify_block: Proc.new do |language|
                                       AvailableDefaultLanguages.all_languages.include?(language)
                                     end),
        FastlaneCore::ConfigItem.new(key: :skip_itc,
                                     short_option: "-i",
                                     env_name: "PRODUCE_SKIP_ITC",
                                     description: "Skip ITC",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :skip_devcenter,
                                     short_option: "-d",
                                     env_name: "PRODUCE_SKIP_DEVCENTER",
                                     description: "Skip Developer Center",
                                     is_string: false,
                                     default_value: false)
        
      ]
    end
  end
end
