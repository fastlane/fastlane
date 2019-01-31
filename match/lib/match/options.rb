require 'fastlane_core/configuration/config_item'
require 'credentials_manager/appfile_config'
require_relative 'module'

module Match
  class Options
    # This is match specific, as users can append storage specific options
    def self.append_option(option)
      self.available_options # to ensure we created the initial `@available_options` array
      @available_options << option
    end

    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        # main
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
        FastlaneCore::ConfigItem.new(key: :readonly,
                                     env_name: "MATCH_READONLY",
                                     description: "Only fetch existing certificates and profiles, don't generate new ones",
                                     is_string: false,
                                     default_value: false),

        # app
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "MATCH_APP_IDENTIFIER",
                                     description: "The bundle identifier(s) of your app (comma-separated)",
                                     is_string: false,
                                     type: Array, # we actually allow String and Array here
                                     skip_type_validation: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                     default_value_dynamic: true),
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "MATCH_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: user,
                                     default_value_dynamic: true),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "FASTLANE_TEAM_ID",
                                     description: "The ID of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     default_value_dynamic: true),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-l",
                                     env_name: "FASTLANE_TEAM_NAME",
                                     description: "The name of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                     default_value_dynamic: true),

        # Storage
        FastlaneCore::ConfigItem.new(key: :storage_mode,
                                     env_name: "MATCH_STORAGE_MODE",
                                     description: "Define where you want to store your certificates",
                                     is_string: true,
                                     short_option: "-q",
                                     default_value: 'git',
                                     verify_block: proc do |value|
                                       unless Match.storage_modes.include?(value)
                                         UI.user_error!("Unsupported storage_mode #{value}, must be in #{Match.storage_modes.join(', ')}")
                                       end
                                     end),

        # Storage: Git
        FastlaneCore::ConfigItem.new(key: :git_url,
                                     env_name: "MATCH_GIT_URL",
                                     description: "URL to the git repo containing all the certificates",
                                     optional: false,
                                     short_option: "-r"),
        FastlaneCore::ConfigItem.new(key: :git_branch,
                                     env_name: "MATCH_GIT_BRANCH",
                                     description: "Specific git branch to use",
                                     default_value: 'master'),
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

        # Storage: Google Cloud
        FastlaneCore::ConfigItem.new(key: :google_cloud_bucket_name,
                                     env_name: "MATCH_GOOGLE_CLOUD_BUCKET_NAME",
                                     description: "Name of the Google Cloud Storage bucket to use",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :google_cloud_keys_file,
                                     env_name: "MATCH_GOOGLE_CLOUD_KEYS_FILE",
                                     description: "Path to the gc_keys.json file",
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find keys file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :google_cloud_project_id,
                                     env_name: "MATCH_GOOGLE_CLOUD_PROJECT_ID",
                                     description: "ID of the Google Cloud project to use for authentication",
                                     optional: true),

        # Keychain
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

        # settings
        FastlaneCore::ConfigItem.new(key: :force,
                                     env_name: "MATCH_FORCE",
                                     description: "Renew the provisioning profiles every time you run match",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :force_for_new_devices,
                                     env_name: "MATCH_FORCE_FOR_NEW_DEVICES",
                                     description: "Renew the provisioning profiles if the device count on the developer portal has changed. Ignored for profile type 'appstore'",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :skip_confirmation,
                                     env_name: "MATCH_SKIP_CONFIRMATION",
                                     description: "Disables confirmation prompts during nuke, answering them with yes",
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
                                     description: "The name of provisioning profile template. If the developer account has provisioning profile templates (aka: custom entitlements), the template name can be found by inspecting the Entitlements drop-down while creating/editing a provisioning profile (e.g. \"Apple Pay Pass Suppression Development\")",
                                     optional: true,
                                     default_value: nil),
        FastlaneCore::ConfigItem.new(key: :output_path,
                                     env_name: "MATCH_OUTPUT_PATH",
                                     description: "Path in which to export certificates, key and profile",
                                     optional: true),

        # other
        FastlaneCore::ConfigItem.new(key: :verbose,
                                     env_name: "MATCH_VERBOSE",
                                     description: "Print out extra information and all commands",
                                     is_string: false,
                                     default_value: false,
                                     verify_block: proc do |value|
                                       FastlaneCore::Globals.verbose = true if value
                                     end)
      ]
    end
  end
end
