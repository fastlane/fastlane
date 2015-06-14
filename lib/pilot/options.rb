require 'fastlane_core'
require 'credentials_manager'

module Pilot
  class Options
    def self.available_options
      @@options ||= [
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "PILOT_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: ENV["DELIVER_USER"] || CredentialsManager::AppfileConfig.try_fetch_value(:apple_id),
                                     verify_block: Proc.new do |value|
                                       CredentialsManager::PasswordManager.shared_manager(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :ipa,
                                     short_option: "-i",
                                     env_name: "PILOT_IPA",
                                     description: "Path to the ipa file to upload",
                                     default_value: Dir["*.ipa"].first,
                                     verify_block: Proc.new do |value|
                                       raise "Could not find ipa file at path '#{value}'" unless File.exists?value
                                       raise "'#{value}' doesn't seem to be an ipa file" unless value.end_with?".ipa"
                                     end)
        
      ]
    end
  end
end
