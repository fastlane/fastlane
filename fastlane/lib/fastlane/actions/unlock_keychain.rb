module Fastlane
  module Actions
    class UnlockKeychainAction < Action
      def self.run(params)
        keychain_path = FastlaneCore::Helper.keychain_path(params[:path])
        add_to_search_list = params[:add_to_search_list]
        set_default = params[:set_default]
        commands = []

        # add to search list if not already added
        if add_to_search_list == true || add_to_search_list == :add
          commands << add_keychain_to_search_list(keychain_path)
        elsif add_to_search_list == :replace
          commands << replace_keychain_in_search_list(keychain_path)
        end

        # set default keychain
        if set_default
          commands << default_keychain(keychain_path)
        end

        escaped_path = keychain_path.shellescape
        escaped_password = params[:password].shellescape

        # Log the full path, useful for troubleshooting
        UI.message("Unlocking keychain at path: #{escaped_path}")
        # unlock given keychain and disable lock and timeout
        commands << Fastlane::Actions.sh("security unlock-keychain -p #{escaped_password} #{escaped_path}", log: false)
        commands << Fastlane::Actions.sh("security set-keychain-settings #{escaped_path}", log: false)
        commands
      end

      def self.add_keychain_to_search_list(keychain_path)
        keychains = Fastlane::Actions.sh("security list-keychains -d user", log: false).shellsplit

        # add the keychain to the keychain list
        unless keychains.include?(keychain_path)
          keychains << keychain_path

          Fastlane::Actions.sh("security list-keychains -s #{keychains.shelljoin}", log: false)
        end
      end

      def self.replace_keychain_in_search_list(keychain_path)
        Actions.lane_context[Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN] = Fastlane::Actions.sh("security default-keychain", log: false).strip
        escaped_path = keychain_path.shellescape
        Fastlane::Actions.sh("security list-keychains -s #{escaped_path}", log: false)
      end

      def self.default_keychain(keychain_path)
        escaped_path = keychain_path.shellescape
        Fastlane::Actions.sh("security default-keychain -s #{escaped_path}", log: false)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Unlock a keychain"
      end

      def self.details
        [
          "Unlocks the given keychain file and adds it to the keychain search list.",
          "Keychains can be replaced with `add_to_search_list: :replace`."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_UNLOCK_KEYCHAIN_PATH",
                                       description: "Path to the keychain file",
                                       default_value: "login",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_UNLOCK_KEYCHAIN_PASSWORD",
                                       sensitive: true,
                                       description: "Keychain password",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :add_to_search_list,
                                       env_name: "FL_UNLOCK_KEYCHAIN_ADD_TO_SEARCH_LIST",
                                       description: "Add to keychain search list",
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :set_default,
                                       env_name: "FL_UNLOCK_KEYCHAIN_SET_DEFAULT",
                                       description: "Set as default keychain",
                                       is_string: false,
                                       default_value: false)

        ]
      end

      def self.authors
        ["xfreebird"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'unlock_keychain( # Unlock an existing keychain and add it to the keychain search list
            path: "/path/to/KeychainName.keychain",
            password: "mysecret"
          )',
          'unlock_keychain( # By default the keychain is added to the existing. To replace them with the selected keychain you may use `:replace`
            path: "/path/to/KeychainName.keychain",
            password: "mysecret",
            add_to_search_list: :replace # To only add a keychain use `true` or `:add`.
          )',
          'unlock_keychain( # In addition, the keychain can be selected as a default keychain
            path: "/path/to/KeychainName.keychain",
            password: "mysecret",
            set_default: true
          )',
          'unlock_keychain( # If the keychain file is located in the standard location `~/Library/Keychains`, then it is sufficient to provide the keychain file name, or file name with its suffix.
            path: "KeychainName",
            password: "mysecret"
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
