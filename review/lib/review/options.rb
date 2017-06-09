require 'fastlane_core'
require 'credentials_manager'
Dir[File.dirname(__FILE__) + '/rules/*.rb'].each { |file| require file }

module Review
  class Options
    def self.rules
      [
        AppleThingsRule,
        PlaceholderWordsRule,
        OtherPlatformsRule,
        FutureFunctionalityRule,
        TestWordsRule,
        CurseWordsRule,
        UnreachableURLRule
      ].map(&:new)
    end

    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "REVIEW_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "REVIEW_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: user),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "REVIEW_TEAM_ID",
                                     description: "The ID of your iTunes Connect team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-l",
                                     env_name: "REVIEW_TEAM_NAME",
                                     description: "The name of your iTunes Connect team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                     end)
      ]
    end
  end
end
