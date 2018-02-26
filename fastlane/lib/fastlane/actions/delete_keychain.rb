require 'shellwords'

module Fastlane
  module Actions
    class DeleteKeychainAction < Action
      def self.run(params)
        original = Actions.lane_context[Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN]

        if params[:keychain_path]
          if File.exist?(params[:keychain_path])
            keychain_path = params[:keychain_path]
            complete_delete(original, keychain_path)
          else
            if params[:throw_error] == true
              UI.user_error!("Unable to find the specified keychain.")
            end
          end
        elsif params[:name]
          # get default keychains list
          default_path = Fastlane::Actions.sh("security list-keychains", log: false).split

          # iterate to find any of the items in the list matches with paramater name
          does_keychain_exists = true
          default_path.each do |path_to_keychain|
            # sometimes keychain saved as name.keychain-db, check that case too
            if path_to_keychain.include?(params[:name]) == true || path_to_keychain.include?("#{params[:name]}-db") == true
              keychain_path = FastlaneCore::Helper.keychain_path(params[:name])
              if File.exist?(keychain_path)
                complete_delete(original, keychain_path)
              else
                does_keychain_exists = false
              end
            else
              does_keychain_exists = false
            end
          end
          # rubocop doesn't allow nested if-else so here is a terrible solution to display errors
          if params[:throw_error] == true && does_keychain_exists == false
            UI.user_error!("Unable to find the specified keychain.")
          end

        else
          UI.user_error!("You either have to set :name or :keychain_path")
        end
      end

      def self.complete_delete(org, path)
        UI.message("Trying to delete the keychain #{path}")
        Fastlane::Actions.sh("security default-keychain -s #{org}", log: false) unless org.nil?
        Fastlane::Actions.sh("security delete-keychain #{path.shellescape}", log: false)
        return
      end

      def self.details
        "Keychains can be deleted after being creating with `create_keychain`"
      end

      def self.description
        "Delete keychains and remove them from the search list"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "KEYCHAIN_NAME",
                                       description: "Keychain name",
                                       conflicting_options: [:keychain_path],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :keychain_path,
                                       env_name: "KEYCHAIN_PATH",
                                       description: "Keychain path",
                                       conflicting_options: [:name],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :throw_error,
                                       env_name: "KEYCHAIN_THROW_ERROR",
                                       description: "Keychain throws error if delete fails",
                                       is_string: false,
                                       default_value: true,
                                       optional: true)
        ]
      end

      def self.example_code
        [
          'delete_keychain(name: "KeychainName")',
          'delete_keychain(name: "KeychainName", throw_error:false)',
          'delete_keychain(keychain_path: "/keychains/project.keychain")'
        ]
      end

      def self.category
        :misc
      end

      def self.authors
        ["gin0606", "koenpunt"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
