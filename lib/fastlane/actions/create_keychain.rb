require 'shellwords'

module Fastlane
  module Actions
    class CreateKeychainAction < Action
      def self.run(params)
        escaped_name = params[:name].shellescape
        escaped_password = params[:password].shellescape

        commands = []
        commands << sh("security create-keychain -p #{escaped_password} #{escaped_name}")

        commands << sh("security default-keychain -s #{escaped_name}") if params[:default_keychain]
        commands << sh("security unlock-keychain -p #{escaped_password} #{escaped_name}") if params[:unlock]

        command = "security set-keychain-settings"
        command << " -t #{params[:timeout]}" if params[:timeout]
        command << " -l" if params[:lock_when_sleeps]
        command << " -u" if params[:lock_after_timeout]
        command << " ~/Library/Keychains/#{escaped_name}"

        commands << sh(command)
        commands
      end

      def self.description
        "Create keychains"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "KEYCHAIN_NAME",
                                       description: "Keychain name",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "KEYCHAIN_PASSWORD",
                                       description: "Password for the keychain",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :default_keychain,
                                       description: 'Set the default keychain',
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :unlock,
                                       description: 'Unlock keychain after create',
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :timeout,
                                       description: 'timeout interval in seconds. Set `false` if you want to specify "no time-out"',
                                       is_string: false,
                                       default_value: 300),
          FastlaneCore::ConfigItem.new(key: :lock_when_sleeps,
                                       description: 'Lock keychain when the system sleeps',
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :lock_after_timeout,
                                       description: 'Lock keychain after timeout interval',
                                       is_string: false,
                                       default_value: false),
        ]
      end

      def self.authors
        ["gin0606"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
