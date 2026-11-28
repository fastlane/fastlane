require 'security'

module Fastlane
  module Actions
    module SharedValues
      ORIGINAL_DEFAULT_KEYCHAIN = :ORIGINAL_DEFAULT_KEYCHAIN
      KEYCHAIN_PATH = :KEYCHAIN_PATH
    end

    class CreateKeychainAction < Action
      def self.run(params)
        keychain_path = params[:name] ? "~/Library/Keychains/#{params[:name]}" : params[:path]

        if keychain_path.nil?
          UI.user_error!("You either have to set :name or :path")
        end

        keychain = Security::Keychain.new(File.expand_path(keychain_path))
        if !exists?(keychain_path)
          begin
            Security::Keychain.create(keychain.filename, params[:password])
          rescue Security::Error => e
            UI.user_error!("Could not create keychain '#{keychain_path}': #{e.message}")
          end
        elsif params[:require_create]
          UI.abort_with_message!("`require_create` option passed, but found keychain '#{keychain_path}', failing create_keychain action")
        else
          UI.important("Found keychain '#{keychain_path}', creation skipped")
          UI.important("If creating a new Keychain DB is required please set the `require_create` option true to cause the action to fail")
        end

        Actions.lane_context[Actions::SharedValues::KEYCHAIN_PATH] = keychain_path

        if params[:default_keychain]
          # if there is no default keychain - setting the original will fail - silent this error
          begin
            Actions.lane_context[Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN] = Security::Keychain.default_keychain&.filename
          rescue Security::Error
          end
          UI.user_error!("Could not make '#{keychain_path}' the default keychain") unless Security::Keychain.set_default_keychain(keychain)
        end

        if params[:unlock] && !keychain.unlock(params[:password])
          UI.user_error!("Could not unlock keychain '#{keychain_path}'")
        end

        # https://ss64.com/osx/security-keychain-settings.html
        # omitting 'timeout' option to specify "no timeout" if required
        timeout = params[:timeout] if params[:timeout] > 0
        unless keychain.update_settings(timeout: timeout, lock_when_sleeping: params[:lock_when_sleeps], lock_after_timeout: params[:lock_after_timeout])
          UI.user_error!("Could not change the settings of keychain '#{keychain_path}'")
        end

        if params[:add_to_search_list]
          keychains = list_keychains
          expanded_path = resolved_keychain_path(keychain_path)
          if keychains.include?(expanded_path)
            UI.important("Found keychain '#{expanded_path}' in list-keychains, adding to search list skipped")
          else
            UI.user_error!("Could not add '#{expanded_path}' to the keychain search list") unless Security::Keychain.set_search_list(keychains + [expanded_path])
          end
        end
      end

      def self.list_keychains
        Security::Keychain.list(:user).map(&:filename)
      end

      def self.exists?(keychain_path)
        !resolved_keychain_path(keychain_path).nil?
      end

      # returns the expanded and resolved path for the keychain, or nil if not found
      def self.resolved_keychain_path(keychain_path)
        keychain_path = File.expand_path(keychain_path)

        # Creating Keychains using the security
        # CLI appends `-db` to the file name.
        ["#{keychain_path}-db", keychain_path].each do |path|
          return path if File.exist?(path)
        end
        nil
      end

      def self.description
        "Create a new Keychain"
      end

      def self.output
        [
          ['ORIGINAL_DEFAULT_KEYCHAIN', 'The path to the default keychain'],
          ['KEYCHAIN_PATH', 'The path of the keychain']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "KEYCHAIN_NAME",
                                       description: "Keychain name",
                                       conflicting_options: [:path],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "KEYCHAIN_PATH",
                                       description: "Path to keychain",
                                       conflicting_options: [:name],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "KEYCHAIN_PASSWORD",
                                       description: "Password for the keychain",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :default_keychain,
                                       description: 'Should the newly created Keychain be the new system default keychain',
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :unlock,
                                       description: 'Unlock keychain after create',
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :timeout,
                                       description: 'timeout interval in seconds. Set `0` if you want to specify "no time-out"',
                                       type: Integer,
                                       default_value: 300),
          FastlaneCore::ConfigItem.new(key: :lock_when_sleeps,
                                       description: 'Lock keychain when the system sleeps',
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :lock_after_timeout,
                                       description: 'Lock keychain after timeout interval',
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :add_to_search_list,
                                       description: 'Add keychain to search list',
                                       type: Boolean,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :require_create,
                                       description: 'Fail the action if the Keychain already exists',
                                       type: Boolean,
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
