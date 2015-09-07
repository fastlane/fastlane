module Fastlane
  module Actions
    class UnlockKeychainAction < Action
      def self.run(params)
        @keychain_path = params[:path]
        add_to_search_list = params[:add_to_search_list]

        if !keychainfile_exists?
          raise "Could not find the keychain file: #{@keychain_path}".red
        end

        # add to search list if not already added
        if add_to_search_list
          add_keychain_to_search_list
        end

        escaped_path = @keychain_path.shellescape
        escaped_password = params[:password].shellescape

        commands = []
        # unlock given keychain and disable lock and timeout
        commands << Fastlane::Actions.sh("security unlock-keychain -p #{escaped_password} #{escaped_path}", log: false)
        commands << Fastlane::Actions.sh("security set-keychain-settings #{escaped_path}", log: false)
        commands
      end

      def self.add_keychain_to_search_list
        escaped_path = @keychain_path.shellescape

        result = Fastlane::Actions.sh("security list-keychains", log: false)

        # add the keychain to the keychains list
        # the basic strategy is to open the keychain file it with Keychain Access
        if !result.include?(@keychain_path)
          commands = []
          commands << Fastlane::Actions.sh("open #{escaped_path}")
          commands
        end
      end

      def self.keychainfile_exists?
        possible_locations = []
        possible_locations << @keychain_path
        possible_locations << "~/Library/Keychains/#{@keychain_path}"
        possible_locations << "~/Library/Keychains/#{@keychain_path}.keychain"

        possible_locations.each do |location|
          expaded_location = File.expand_path(location)
          if File.exist?(expaded_location)
            @keychain_path = expaded_location
            return true
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Unlock a keychain"
      end

      def self.details
        "Unlocks the give keychain file and it adds it to the keychain search list."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_UNLOCK_KEYCHAIN_PATH",
                                       description: "Path to the Keychain file",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_UNLOCK_KEYCHAIN_PASSWORD",
                                       description: "Keychain password",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :add_to_search_list,
                                       env_name: "FL_UNLOCK_KEYCHAIN_ADD_TO_SEARCH_LIST",
                                       description: "Add to keychain search list",
                                       is_string: false,
                                       default_value: true)

        ]
      end

      def self.authors
        ["xfreebird"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
