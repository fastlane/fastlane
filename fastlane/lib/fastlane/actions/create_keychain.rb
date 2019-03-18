require 'shellwords'

module Fastlane
  module Actions
    module SharedValues
      ORIGINAL_DEFAULT_KEYCHAIN = :ORIGINAL_DEFAULT_KEYCHAIN
    end

    class CreateKeychainAction < Action
      def self.run(params)
        escaped_password = params[:password].shellescape

        if params[:name]
          escaped_name = params[:name].shellescape
          keychain_path = "~/Library/Keychains/#{escaped_name}"
        else
          keychain_path = params[:path].shellescape
        end

        if keychain_path.nil?
          UI.user_error!("You either have to set :name or :path")
        end

        commands = []

        if !exists?(keychain_path)
          commands << Fastlane::Actions.sh("security create-keychain -p #{escaped_password} #{keychain_path}", log: false)
        elsif params[:require_create]
          UI.abort_with_message!("`require_create` option passed, but found keychain '#{keychain_path}', failing create_keychain action")
        else
          UI.important("Found keychain '#{keychain_path}', creation skipped")
          UI.important("If creating a new Keychain DB is required please set the `require_create` option true to cause the action to fail")
        end

        if params[:default_keychain]
          # if there is no default keychain - setting the original will fail - silent this error
          begin
            Actions.lane_context[Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN] = Fastlane::Actions.sh("security default-keychain", log: false).strip
          rescue
          end
          commands << Fastlane::Actions.sh("security default-keychain -s #{keychain_path}", log: false)
        end

        commands << Fastlane::Actions.sh("security unlock-keychain -p #{escaped_password} #{keychain_path}", log: false) if params[:unlock]

        command = "security set-keychain-settings"
        command << " -t #{params[:timeout]}" if params[:timeout]
        command << " -l" if params[:lock_when_sleeps]
        command << " -u" if params[:lock_after_timeout]
        command << " #{keychain_path}"

        commands << Fastlane::Actions.sh(command, log: false)

        if params[:add_to_search_list]
          keychains = Action.sh("security list-keychains -d user").shellsplit
          keychains << File.expand_path(keychain_path)
          commands << Fastlane::Actions.sh("security list-keychains -s #{keychains.shelljoin}", log: false)
        end

        commands
      end

      def self.exists?(keychain_path)
        keychain_path = File.expand_path(keychain_path)

        # Creating Keychains using the security
        # CLI appends `-db` to the file name.
        File.exist?("#{keychain_path}-db") || File.exist?(keychain_path)
      end

      def self.description
        "Create a new Keychain"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "KEYCHAIN_NAME",
                                       description: "Keychain name",
                                       conflicting_options: [:path],
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "KEYCHAIN_PATH",
                                       description: "Path to keychain",
                                       is_string: true,
                                       conflicting_options: [:name],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "KEYCHAIN_PASSWORD",
                                       description: "Password for the keychain",
                                       sensitive: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :default_keychain,
                                       description: 'Should the newly created Keychain be the new system default keychain',
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
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :require_create,
                                       description: 'Fail the action if the Keychain already exists',
                                       is_string: false,
                                       default_value: false)
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
