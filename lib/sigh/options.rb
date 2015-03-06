require 'fastlane_core'

module Sigh
  class Options
    def self.available_options
      @@options ||= [
        FastlaneCore::ConfigItem.new(key: :adhoc, 
                                env_name: "SIGH_AD_HOC", 
                             description: "Setting this flag will generate AdHoc profiles instead of App Store Profiles",
                               is_string: false),
        FastlaneCore::ConfigItem.new(key: :skip_install, 
                                env_name: "SIGH_SKIP_INSTALL", 
                             description: "By default, the certificate will be added on your local machine. Setting this flag will skip this action",
                               is_string: false),
        FastlaneCore::ConfigItem.new(key: :development, 
                                env_name: "SIGH_DEVELOPMENT", 
                             description: "Renew the development certificate instead of the production one",
                               is_string: false),
        FastlaneCore::ConfigItem.new(key: :force, 
                                env_name: "SIGH_FORCE", 
                             description: "Renew non-development provisioning profiles regardless of its state",
                               is_string: false),
        FastlaneCore::ConfigItem.new(key: :app_identifier, 
                            short_option: "-a",
                                env_name: "SIGH_APP_IDENTIFIER", 
                             description: "The bundle identifier of your app",
                           default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :username, 
                            short_option: "-u",
                                env_name: "SIGH_USERNAME", 
                             description: "Your Apple ID Username",
                           default_value: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id),
                            verify_block: Proc.new do |value|
                              # CredentialsManager::PasswordManager.shared_manager(value)
                            end),
        FastlaneCore::ConfigItem.new(key: :provisioning_file_name, 
                            short_option: "-n",
                                env_name: "SIGH_PROVISIONING_PROFILE_NAME", 
                             description: "The name of the generated certificate file"),
        FastlaneCore::ConfigItem.new(key: :output_path,
                            short_option: "-o", 
                                env_name: "SIGH_OUTPUT_PATH", 
                             description: "Directory in which the profile should be stored",
                           default_value: ".",
                            verify_block: Proc.new do |value|
                              raise "Could not find output directory '#{value}'".red unless File.exists?(value)
                            end),
        FastlaneCore::ConfigItem.new(key: :cert_id, 
                            short_option: "-i",
                                env_name: "SIGH_CERTIFICATE_ID", 
                             description: "The ID of the certificate to use",
                                optional: true),
        FastlaneCore::ConfigItem.new(key: :cert_owner_name, 
                            short_option: "-c",
                                env_name: "SIGH_CERTIFICATE", 
                             description: "The certificate name to use for new profiles, or to renew with. (e.g. \"Felix Krause\")",
                                optional: true),
        FastlaneCore::ConfigItem.new(key: :cert_date, 
                            short_option: "-d",
                                env_name: "SIGH_CERTIFICATE_EXPIRE_DATE", 
                             description: "The certificate with the given expiry date used to renew. (e.g. \"Nov 11, 2017\")",
                                optional: true),
        FastlaneCore::ConfigItem.new(key: :filename, 
                            short_option: "-f",
                                env_name: "SIGH_PROFILE_FILE_NAME", 
                                optional: true,
                             description: "Filename to use for the generated provisioning profile (must include .mobileprovision)",
                            verify_block: Proc.new do |value|
                              raise "The output name must end with .mobileprovision".red unless value.end_with?".mobileprovision"
                            end)
      ]
    end
  end
end