require 'fastlane_core'
require 'credentials_manager'

module Fastfix
  class Options
    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :path,
                                     env_name: "FASTFIX_PATH",
                                     description: "Path to the certificates directory",
                                     default_value: File.join('fastlane', 'certificates'),
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :git_url,
                                     env_name: "FASTFIX_GIT_URl",
                                     description: "URL to the git repo containing all the certificates",
                                     optional: false,
                                     short_option: "-r",
                                     verify_block: proc do |value|
                                       # TODO
                                     end),
        FastlaneCore::ConfigItem.new(key: :type,
                                     env_name: "FASTFIX_TYPE",
                                     description: "Create a development certificate instead of a distribution one",
                                     is_string: true,
                                     short_option: "-y",
                                     default_value: 'development',
                                     verify_block: proc do |value|
                                       supported = %w(appstore adhoc development enterprise)
                                       unless supported.include?(value)
                                         raise "Unsupported environment #{value}, must be in #{supported.join(', ')}".red
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                   short_option: "-a",
                                   env_name: "FASTFIX_APP_IDENTIFIER",
                                   description: "The bundle identifier of your app",
                                   default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "FASTFIX_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: user),
        FastlaneCore::ConfigItem.new(key: :keychain_name,
                                     env_name: "FASTFIX_KEYCHAIN_NAME",
                                     description: "Keychain the items should be imported to",
                                     default_value: "login.keychain"),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "FASTFIX_TEAM_ID",
                                     description: "The ID of your team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-l",
                                     env_name: "FASTFIX_TEAM_NAME",
                                     description: "The name of your team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_NAME"] = value
                                     end),
        FastlaneCore::ConfigItem.new(key: :force,
                                     env_name: "FASTFIX_FORCE",
                                     description: "Renew provisioning profiles regardless of its state",
                                     is_string: false,
                                     default_value: false)
      ]
    end
  end
end
