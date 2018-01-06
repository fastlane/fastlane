require 'fastlane_core/configuration/config_item'
require 'credentials_manager/appfile_config'
require_relative 'module'

module Match
  class Options
    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :git_url,
                                     env_name: "MATCH_GIT_URL",
                                     description: "URL to the git repo containing all the certificates",
                                     optional: false,
                                     short_option: "-r"),
        FastlaneCore::ConfigItem.new(key: :git_branch,
                                     env_name: "MATCH_GIT_BRANCH",
                                     description: "Specific git branch to use",
                                     default_value: 'master'),
        FastlaneCore::ConfigItem.new(key: :type,
                                     env_name: "MATCH_TYPE",
                                     description: "Define the profile type, can be #{Match.environments.join(', ')}",
                                     is_string: true,
                                     short_option: "-y",
                                     default_value: 'development',
                                     verify_block: proc do |value|
                                       unless Match.environments.include?(value)
                                         UI.user_error!("Unsupported environment #{value}, must be in #{Match.environments.join(', ')}")
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "MATCH_APP_IDENTIFIER",
                                     description: "The bundle identifier(s) of your app (comma-separated)",
                                     is_string: false,
                                     type: Array, # we actually allow String and Array here
                                     skip_type_validation: true,
                                     code_gen_sensitive: true,
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
        FastlaneCore::ConfigItem.new(key: :keychain_password,
                                     short_option: "-p",
                                     env_name: "MATCH_KEYCHAIN_PASSWORD",
                                     sensitive: true,
                                     description: "This might be required the first time you access certificates on a new mac. For the login/default keychain this is your account password",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :readonly,
                                     env_name: "MATCH_READONLY",
                                     description: "Only fetch existing certificates and profiles, don't generate new ones",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "FASTLANE_TEAM_ID",
                                     description: "The ID of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :git_full_name,
                                     env_name: "MATCH_GIT_FULL_NAME",
                                     description: "git user full name to commit",
                                     optional: true,
                                     default_value: nil),
        FastlaneCore::ConfigItem.new(key: :git_user_email,
                                     env_name: "MATCH_GIT_USER_EMAIL",
                                     description: "git user email to commit",
                                     optional: true,
                                     default_value: nil),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-l",
                                     env_name: "FASTLANE_TEAM_NAME",
                                     description: "The name of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :verbose,
                                     env_name: "MATCH_VERBOSE",
                                     description: "Print out extra information and all commands",
                                     is_string: false,
                                     default_value: false,
                                     verify_block: proc do |value|
                                       FastlaneCore::Globals.verbose = true if value
                                     end),
        FastlaneCore::ConfigItem.new(key: :force,
                                     env_name: "MATCH_FORCE",
                                     description: "Renew the provisioning profiles every time you run match",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :skip_confirmation,
                                     env_name: "MATCH_SKIP_CONFIRMATION",
                                     description: "Disables confirmation prompts during nuke, answering them with yes",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :shallow_clone,
                                     env_name: "MATCH_SHALLOW_CLONE",
                                     description: "Make a shallow clone of the repository (truncate the history to 1 revision)",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :clone_branch_directly,
                                     env_name: "MATCH_CLONE_BRANCH_DIRECTLY",
                                     description: "Clone just the branch specified, instead of the whole repo. This requires that the branch already exists. Otherwise the command will fail",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :workspace,
                                     description: nil,
                                     verify_block: proc do |value|
                                       unless Helper.test?
                                         if value.start_with?("/var/folders") or value.include?("tmp/") or value.include?("temp/")
                                           # that's fine
                                         else
                                           UI.user_error!("Specify the `git_url` instead of the `path`")
                                         end
                                       end
                                     end,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :force_for_new_devices,
                                     env_name: "MATCH_FORCE_FOR_NEW_DEVICES",
                                     description: "Renew the provisioning profiles if the device count on the developer portal has changed. Ignored for profile type 'appstore'",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :skip_docs,
                                     env_name: "MATCH_SKIP_DOCS",
                                     description: "Skip generation of a README.md for the created git repository",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :platform,
                                     short_option: '-o',
                                     env_name: "MATCH_PLATFORM",
                                     description: "Set the provisioning profile's platform to work with (i.e. ios, tvos)",
                                     is_string: false,
                                     default_value: "ios",
                                     verify_block: proc do |value|
                                       value = value.to_s
                                       pt = %w(tvos ios)
                                       UI.user_error!("Unsupported platform, must be: #{pt}") unless pt.include?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :template_name,
                                     env_name: "MATCH_PROVISIONING_PROFILE_TEMPLATE_NAME",
                                     description: "The name of provisioning profile template. If the developer account has provisioning profile templates, template name can be found by inspecting the Entitlements drop-down while creating/editing a provisioning profile",
                                     optional: true,
                                     default_value: nil)
      ]
    end
  end
end
