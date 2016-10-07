require 'shellwords'

module Fastlane
  module Actions
    module SharedValues
      ORIGINAL_DEFAULT_KEYCHAIN = :ORIGINAL_DEFAULT_KEYCHAIN
    end

    class CreateKeychainAction < Action
      def self.run(params)
        escaped_name = params[:name].shellescape
        escaped_password = params[:password].shellescape

        commands = []
        commands << Fastlane::Actions.sh("security create-keychain -p #{escaped_password} #{escaped_name}", log: false)

        if params[:default_keychain]
          Actions.lane_context[Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN] = Fastlane::Actions.sh("security default-keychain", log: false).strip
          commands << Fastlane::Actions.sh("security default-keychain -s #{escaped_name}", log: false)
        end

        commands << Fastlane::Actions.sh("security unlock-keychain -p #{escaped_password} #{escaped_name}", log: false) if params[:unlock]

        command = "security set-keychain-settings"
        command << " -t #{params[:timeout]}" if params[:timeout]
        command << " -l" if params[:lock_when_sleeps]
        command << " -u" if params[:lock_after_timeout]
        command << " ~/Library/Keychains/#{escaped_name}"

        commands << Fastlane::Actions.sh(command, log: false)

        if params[:add_to_search_list]
          keychains = Action.sh("security list-keychains -d user").shellsplit
          keychains << File.expand_path(params[:name], "~/Library/Keychains")
          commands << Fastlane::Actions.sh("security list-keychains -s #{keychains.shelljoin}", log: false)
        end

        commands
      end

      def self.description
        "Create a new Keychain"
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
          FastlaneCore::ConfigItem.new(key: :add_to_search_list,
                                       description: 'Add keychain to search list',
                                       is_string: false,
                                       default_value: true)
        ]
      end

      def self.authors
        ["gin0606"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'create_keychain(
            name: "KeychainName",
            default_keychain: true,
            unlock: true,
            timeout: 3600,
            lock_when_sleeps: true
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
