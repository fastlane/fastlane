require 'fastlane_core'
require 'credentials_manager'

module Supply
  class Options
    def self.available_options
      @options ||= [
        FastlaneCore::ConfigItem.new(key: :package_name,
                                     env_name: "SUPPLY_PACKAGE_NAME",
                                     short_option: "-p",
                                     description: "The package name of the Application to modify",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:package_name)),
        FastlaneCore::ConfigItem.new(key: :track,
                                     short_option: "-a",
                                     env_name: "SUPPLY_TRACK",
                                     description: "The Track to upload the Application to: production, beta, alpha or rollout",
                                     default_value: 'production',
                                     verify_block: proc do |value|
                                       available = %w(production beta alpha rollout)
                                       raise "Invalid value '#{value}', must be #{available.join(', ')}".red unless available.include? value
                                     end),
        FastlaneCore::ConfigItem.new(key: :rollout,
                                     short_option: "-r",
                                     description: "The percentage of the rollout",
                                     default_value: '1.0',
                                     verify_block: proc do |value|
                                       available = %w(0.005 0.01 0.05 0.1 0.2 0.5 1.0)
                                       raise "Invalid value '#{value}', must be #{available.join(', ')}".red unless available.include? value
                                     end),
        FastlaneCore::ConfigItem.new(key: :metadata_path,
                                     env_name: "SUPPLY_METADATA_PATH",
                                     short_option: "-m",
                                     optional: true,
                                     description: "Path to the directory containing the metadata files",
                                     default_value: (Dir["./fastlane/metadata/android"] + Dir["./metadata"]).first,
                                     verify_block: proc do |value|
                                       raise "Could not find folder".red unless File.directory? value
                                     end),
        FastlaneCore::ConfigItem.new(key: :key,
                                     env_name: "SUPPLY_KEY",
                                     description: "The p12 File used to authenticate with Google",
                                     default_value: Dir["*.p12"].first || CredentialsManager::AppfileConfig.try_fetch_value(:keyfile),
                                     verify_block: proc do |value|
                                       raise "Could not find p12 file at path '#{File.expand_path(value)}'".red unless File.exist?(File.expand_path(value))
                                     end),
        FastlaneCore::ConfigItem.new(key: :issuer,
                                     short_option: "-i",
                                     env_name: "SUPPLY_ISSUER",
                                     description: "The issuer of the p12 file (email address of the service account)",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:issuer)),
        FastlaneCore::ConfigItem.new(key: :apk,
                                     env_name: "SUPPLY_APK",
                                     description: "Path to the APK file to upload",
                                     short_option: "-b",
                                     default_value: Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "app-Release.apk")].last,
                                     optional: true,
                                     verify_block: proc do |value|
                                       raise "Could not find apk file at path '#{value}'".red unless File.exist?(value)
                                       raise "apk file is not an apk".red unless value.end_with?(value)
                                     end)
      ]
    end
  end
end
