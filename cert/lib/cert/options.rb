require 'credentials_manager/appfile_config'
require 'fastlane_core/configuration/config_item'

require_relative 'module'

module Cert
  class Options
    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :development,
                                     env_name: "CERT_DEVELOPMENT",
                                     description: "Create a development certificate instead of a distribution one",
                                     type: Boolean,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :type,
                                     env_name: "CERT_TYPE",
                                     description: "Create specific certificate type (takes precedence over :development)",
                                     optional: true,
                                     verify_block: proc do |value|
                                       value = value.to_s
                                       types = %w(mac_installer_distribution developer_id_installer developer_id_application developer_id_kext)
                                       UI.user_error!("Unsupported types, must be: #{types}") unless types.include?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :force,
                                     env_name: "CERT_FORCE",
                                     description: "Create a certificate even if an existing certificate exists",
                                     type: Boolean,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :generate_apple_certs,
                                     env_name: "CERT_GENERATE_APPLE_CERTS",
                                     description: "Create a certificate type for Xcode 11 and later (Apple Development or Apple Distribution)",
                                     type: Boolean,
                                     default_value: FastlaneCore::Helper.mac? && FastlaneCore::Helper.xcode_at_least?('11'),
                                     default_value_dynamic: true),

        # App Store Connect API
        FastlaneCore::ConfigItem.new(key: :api_key_path,
                                     env_names: ["CERT_API_KEY_PATH", "DELIVER_API_KEY_PATH", "APP_STORE_CONNECT_API_KEY_PATH"],
                                     description: "Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)",
                                     optional: true,
                                     conflicting_options: [:api_key],
                                     verify_block: proc do |value|
                                       UI.user_error!("Couldn't find API key JSON file at path '#{value}'") unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :api_key,
                                     env_names: ["CERT_API_KEY", "DELIVER_API_KEY", "APP_STORE_CONNECT_API_KEY"],
                                     description: "Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-hash-option)",
                                     type: Hash,
                                     optional: true,
                                     sensitive: true,
                                     conflicting_options: [:api_key_path]),

        # Apple ID
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "CERT_USERNAME",
                                     description: "Your Apple ID Username",
                                     optional: true,
                                     default_value: user,
                                     default_value_dynamic: true),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "CERT_TEAM_ID",
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     default_value_dynamic: true,
                                     description: "The ID of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-l",
                                     env_name: "CERT_TEAM_NAME",
                                     description: "The name of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                     default_value_dynamic: true,
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                     end),

        # Other Options
        FastlaneCore::ConfigItem.new(key: :filename,
                                     short_option: "-q",
                                     env_name: "CERT_FILE_NAME",
                                     optional: true,
                                     description: "The filename of certificate to store"),
        FastlaneCore::ConfigItem.new(key: :output_path,
                                     short_option: "-o",
                                     env_name: "CERT_OUTPUT_PATH",
                                     description: "The path to a directory in which all certificates and private keys should be stored",
                                     default_value: "."),
        FastlaneCore::ConfigItem.new(key: :keychain_path,
                                     short_option: "-k",
                                     env_name: "CERT_KEYCHAIN_PATH",
                                     description: "Path to a custom keychain",
                                     code_gen_sensitive: true,
                                     default_value: Helper.mac? ? Dir["#{Dir.home}/Library/Keychains/login.keychain", "#{Dir.home}/Library/Keychains/login.keychain-db"].last : nil,
                                     default_value_dynamic: true,
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Keychain is not supported on platforms other than macOS") if !Helper.mac? && value
                                       value = File.expand_path(value)
                                       UI.user_error!("Keychain not found at path '#{value}'") unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :keychain_password,
                                     short_option: "-p",
                                     env_name: "CERT_KEYCHAIN_PASSWORD",
                                     sensitive: true,
                                     description: "This might be required the first time you access certificates on a new mac. For the login/default keychain this is your macOS account password",
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Keychain is not supported on platforms other than macOS") unless Helper.mac?
                                     end),
        FastlaneCore::ConfigItem.new(key: :skip_set_partition_list,
                                     short_option: "-P",
                                     env_name: "CERT_SKIP_SET_PARTITION_LIST",
                                     description: "Skips setting the partition list (which can sometimes take a long time). Setting the partition list is usually needed to prevent Xcode from prompting to allow a cert to be used for signing",
                                     type: Boolean,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :platform,
                                     env_name: "CERT_PLATFORM",
                                     description: "Set the provisioning profile's platform (ios, macos, tvos)",
                                     default_value: "ios",
                                     verify_block: proc do |value|
                                       value = value.to_s
                                       pt = %w(macos ios tvos)
                                       UI.user_error!("Unsupported platform, must be: #{pt}") unless pt.include?(value)
                                     end)
      ]
    end
  end
end
