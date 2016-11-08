require 'fastlane_core'
require 'credentials_manager'

module Sigh
  class Options
    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :adhoc,
                                     env_name: "SIGH_AD_HOC",
                                     description: "Setting this flag will generate AdHoc profiles instead of App Store Profiles",
                                     is_string: false,
                                     default_value: false,
                                     conflicting_options: [:development],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can't enable both :development and :adhoc")
                                     end),
        FastlaneCore::ConfigItem.new(key: :development,
                                     env_name: "SIGH_DEVELOPMENT",
                                     description: "Renew the development certificate instead of the production one",
                                     is_string: false,
                                     default_value: false,
                                     conflicting_options: [:adhoc],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can't enable both :development and :adhoc")
                                     end),
        FastlaneCore::ConfigItem.new(key: :skip_install,
                                     env_name: "SIGH_SKIP_INSTALL",
                                     description: "By default, the certificate will be added on your local machine. Setting this flag will skip this action",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :force,
                                     env_name: "SIGH_FORCE",
                                     description: "Renew provisioning profiles regardless of its state - to automatically add all devices for ad hoc profiles",
                                     is_string: false,
                                     short_option: "-f",
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "SIGH_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "SIGH_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: user),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "SIGH_TEAM_ID",
                                     description: "The ID of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-l",
                                     env_name: "SIGH_TEAM_NAME",
                                     description: "The name of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :provisioning_name,
                                     short_option: "-n",
                                     env_name: "SIGH_PROVISIONING_PROFILE_NAME",
                                     description: "The name of the profile that is used on the Apple Developer Portal",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :ignore_profiles_with_different_name,
                                     env_name: "SIGH_IGNORE_PROFILES_WITH_DIFFERENT_NAME",
                                     description: "Use in combination with :provisioning_name - when true only profiles matching this exact name will be downloaded",
                                     optional: true,
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :output_path,
                                     short_option: "-o",
                                     env_name: "SIGH_OUTPUT_PATH",
                                     description: "Directory in which the profile should be stored",
                                     default_value: "."),
        FastlaneCore::ConfigItem.new(key: :cert_id,
                                     short_option: "-i",
                                     env_name: "SIGH_CERTIFICATE_ID",
                                     description: "The ID of the code signing certificate to use (e.g. 78ADL6LVAA) ",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :cert_owner_name,
                                     short_option: "-c",
                                     env_name: "SIGH_CERTIFICATE",
                                     description: "The certificate name to use for new profiles, or to renew with. (e.g. \"Felix Krause\")",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :filename,
                                     short_option: "-q",
                                     env_name: "SIGH_PROFILE_FILE_NAME",
                                     optional: true,
                                     description: "Filename to use for the generated provisioning profile (must include .mobileprovision)",
                                     verify_block: proc do |value|
                                       UI.user_error!("The output name must end with .mobileprovision") unless value.end_with?(".mobileprovision")
                                     end),
        FastlaneCore::ConfigItem.new(key: :skip_fetch_profiles,
                                     env_name: "SIGH_SKIP_FETCH_PROFILES",
                                     description: "Skips the verification of existing profiles which is useful if you have thousands of profiles",
                                     is_string: false,
                                     default_value: false,
                                     short_option: "-w"),
        FastlaneCore::ConfigItem.new(key: :skip_certificate_verification,
                                     short_option: '-z',
                                     env_name: "SIGH_SKIP_CERTIFICATE_VERIFICATION",
                                     description: "Skips the verification of the certificates for every existing profiles. This will make sure the provisioning profile can be used on the local machine",
                                     is_string: false,
                                     default_value: false)
      ]
    end
  end
end
