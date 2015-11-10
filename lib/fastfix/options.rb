require 'fastlane_core'
require 'credentials_manager'

module Fastfix
  class Options
    def self.available_options
      [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FASTFIX_PATH",
                                       description: "Path to the certificates directory",
                                       default_value: File.join('fastlane', 'certificates'),
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :git_url,
                                       env_name: "FASTFIX_GIT_URl",
                                       description: "URL to the git repo containing all the certificates",
                                       optional: true,
                                       verify_block: proc do |value|
                                         # TODO
                                       end),
          FastlaneCore::ConfigItem.new(key: :type,
                                       env_name: "FASTFIX_TYPE",
                                       description: "Create a development certificate instead of a distribution one",
                                       is_string: false,
                                       verify_block: proc do |value|
                                         value = value.to_sym
                                         supported = [:appstore, :adhoc, :development, :enterprise]
                                         unless supported.include?(value)
                                           raise "Unsupported environment #{value}, must be in #{supported.join(', ')}".red
                                         end
                                       end,
                                       default_value: :appstore),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "FASTFIX_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "FASTFIX_USERNAME",
                                       description: "Your Apple ID Username",
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)),
          FastlaneCore::ConfigItem.new(key: :keychain_name,
                                       env_name: "FASTFIX_KEYCHAIN_NAME",
                                       description: "Keychain the items should be imported to",
                                       default_value: "login.keychain")
        ]
    end
  end
end
