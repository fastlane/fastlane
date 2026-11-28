require 'fastlane_core/configuration/config_item'
require 'credentials_manager/appfile_config'

require_relative 'rules/all'

module Precheck
  class Options
    def self.rules
      [
        NegativeAppleSentimentRule,
        PlaceholderWordsRule,
        OtherPlatformsRule,
        FutureFunctionalityRule,
        TestWordsRule,
        CurseWordsRule,
        FreeStuffIAPRule,
        CustomTextRule,
        CopyrightDateRule,
        UnreachableURLRule
      ].map(&:new)
    end

    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :api_key_path,
                                     env_names: ["PRECHECK_API_KEY_PATH", "APP_STORE_CONNECT_API_KEY_PATH"],
                                     description: "Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)",
                                     optional: true,
                                     conflicting_options: [:username],
                                     verify_block: proc do |value|
                                       UI.user_error!("Couldn't find API key JSON file at path '#{value}'") unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :api_key,
                                     env_names: ["PRECHECK_API_KEY", "APP_STORE_CONNECT_API_KEY"],
                                     description: "Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-hash-option)",
                                     type: Hash,
                                     optional: true,
                                     sensitive: true,
                                     conflicting_options: [:api_key_path, :username]),

        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "PRECHECK_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                     default_value_dynamic: true),
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "PRECHECK_USERNAME",
                                     description: "Your Apple ID Username",
                                     optional: true,
                                     default_value: user,
                                     default_value_dynamic: true),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "PRECHECK_TEAM_ID",
                                     description: "The ID of your App Store Connect team if you're in multiple teams",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                     default_value_dynamic: true,
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-l",
                                     env_name: "PRECHECK_TEAM_NAME",
                                     description: "The name of your App Store Connect team if you're in multiple teams",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                     default_value_dynamic: true,
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :platform,
                                     short_option: "-j",
                                     env_name: "PRECHECK_PLATFORM",
                                     description: "The platform to use (optional)",
                                     optional: true,
                                     default_value: "ios",
                                     verify_block: proc do |value|
                                       UI.user_error!("The platform can only be ios, appletvos/tvos or osx") unless %w(ios appletvos tvos osx).include?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :default_rule_level,
                                     short_option: "-r",
                                     env_name: "PRECHECK_DEFAULT_RULE_LEVEL",
                                     description: "The default rule level unless otherwise configured",
                                     type: Symbol,
                                     default_value: RULE_LEVELS[:error]),
        FastlaneCore::ConfigItem.new(key: :include_in_app_purchases,
                                     short_option: "-i",
                                     env_name: "PRECHECK_INCLUDE_IN_APP_PURCHASES",
                                     description: "Should check in-app purchases?",
                                     type: Boolean,
                                     optional: true,
                                     default_value: true),
        FastlaneCore::ConfigItem.new(key: :use_live,
                                     env_name: "PRECHECK_USE_LIVE",
                                     description: "Should force check live app?",
                                     type: Boolean,
                                     default_value: false)
      ] + rules
    end
  end
end
