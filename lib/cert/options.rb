require 'fastlane_core'

module Cert
  class Options
    def self.available_options
      @@options ||= [
        FastlaneCore::ConfigItem.new(key: :development,
                                     env_name: "CERT_DEVELOPMENT",
                                     description: "Create a development certificate instead of a distribution one",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "CERT_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id),
                                     verify_block: Proc.new do |value|
                                       CredentialsManager::PasswordManager.shared_manager(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-t",
                                     env_name: "CERT_TEAM_ID",
                                     description: "The ID of your team if you're in multiple teams",
                                     optional: true,
                                     verify_block: Proc.new do |value|
                                        ENV["FASTLANE_TEAM_ID"] = value
                                     end),
        FastlaneCore::ConfigItem.new(key: :output_path,
                                     short_option: "-o",
                                     env_name: "CERT_OUTPUT_PATH",
                                     description: "The path to a directory in which all certificates and private keys should be stored",
                                     default_value: "."),
        FastlaneCore::ConfigItem.new(key: :keychain_path,
                                     short_option: "-k",
                                     env_name: "CERT_KEYCHAIN_PATH",
                                     description: "Path to a custom keychain",
                                     optional: true,
                                     verify_block: Proc.new do |value|
                                        raise "Keychain not found at path '#{value}'".red unless File.exists?value
                                     end),
        FastlaneCore::ConfigItem.new(key: :signing_request_path,
                                     short_option: "-s",
                                     env_name: "CERT_SIGNING_REQUEST_PATH",
                                     description: "Path to a signing request file (optional)",
                                     optional: true,
                                     verify_block: Proc.new do |value|
                                        raise "File not found at path '#{value}'".red unless File.exists?value
                                     end)
      ]
    end
  end
end
