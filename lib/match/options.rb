require 'fastlane_core'
require 'credentials_manager'

module Match
  class Options
    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :git_url,
                                     env_name: "MATCH_GIT_URl",
                                     description: "URL to the git repo containing all the certificates",
                                     optional: false,
                                     short_option: "-r",
                                     verify_block: proc do |value|
                                       unless value.start_with?("https://") || value.start_with?("git")
                                         raise "git_url must start with either https:// or git://".red
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :type,
                                     env_name: "MATCH_TYPE",
                                     description: "Create a development certificate instead of a distribution one",
                                     is_string: true,
                                     short_option: "-y",
                                     default_value: 'development',
                                     verify_block: proc do |value|
                                       unless Match.environments.include?(value)
                                         raise "Unsupported environment #{value}, must be in #{Match.environments.join(', ')}".red
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "MATCH_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "MATCH_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: user),
        FastlaneCore::ConfigItem.new(key: :keychain_name,
                                     short_option: "-s",
                                     env_name: "MATCH_KEYCHAIN_NAME",
                                     description: "Keychain the items should be imported to",
                                     default_value: "login.keychain"),
        FastlaneCore::ConfigItem.new(key: :readonly,
                                     env_name: "MATCH_READONLY",
                                     description: "Only fetch existing certificates and profiles, don't generate new ones",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "MATCH_TEAM_ID",
                                     description: "The ID of your team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-l",
                                     env_name: "MATCH_TEAM_NAME",
                                     description: "The name of your team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_NAME"] = value
                                     end),
        FastlaneCore::ConfigItem.new(key: :verbose,
                                     env_name: "MATCH_VERBOSE",
                                     description: "Print out extra information and all commands",
                                     is_string: false,
                                     default_value: false,
                                     verify_block: proc do |value|
                                       $verbose = true if value
                                     end),
        FastlaneCore::ConfigItem.new(key: :force,
                                     env_name: "MATCH_FORCE",
                                     description: "Renew the provisioning profiles every time you run match",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :path,
                                     description: nil,
                                     verify_block: proc do |value|
                                       unless Helper.test?
                                         raise "Specify the `git_url` instead of the `path`".red unless value.start_with?("/var/folders")
                                       end
                                     end,
                                     optional: true)
      ]
    end
  end
end
