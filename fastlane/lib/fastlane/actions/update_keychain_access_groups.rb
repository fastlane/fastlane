module Fastlane
  module Actions
    module SharedValues
      KEYCHAIN_ACCESS_GROUPS = :KEYCHAIN_ACCESS_GROUPS
    end

    class UpdateKeychainAccessGroupsAction < Action
      require 'plist'

      def self.run(params)
        UI.message("Entitlements File: #{params[:entitlements_file]}")
        UI.message("New keychain access groups: #{params[:identifiers]}")

        entitlements_file = params[:entitlements_file]
        UI.user_error!("Could not find entitlements file at path '#{entitlements_file}'") unless File.exist?(entitlements_file)

        # parse entitlements
        result = Plist.parse_xml(entitlements_file)
        UI.user_error!("Entitlements file at '#{entitlements_file}' cannot be parsed.") unless result

        # keychain access groups key
        keychain_access_groups_key = 'keychain-access-groups'

        # get keychain access groups
        keychain_access_groups_field = result[keychain_access_groups_key]
        UI.user_error!("No existing keychain access groups field specified. Please specify an keychain access groups in the entitlements file.") unless keychain_access_groups_field

        # set new keychain access groups
        UI.message("Old keychain access groups: #{keychain_access_groups_field}")
        result[keychain_access_groups_key] = params[:identifiers]

        # save entitlements file
        result.save_plist(entitlements_file)
        UI.message("New keychain access groups: #{result[keychain_access_groups_key]}")

        Actions.lane_context[SharedValues::KEYCHAIN_ACCESS_GROUPS] = result[keychain_access_groups_key]
      end

      def self.description
        "This action changes the keychain access groups in the entitlements file"
      end

      def self.details
        "Updates the Keychain Group Access Groups in the given Entitlements file, so you can have keychain access groups for the app store build and keychain access groups for an enterprise build."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :entitlements_file,
                                       env_name: "FL_UPDATE_KEYCHAIN_ACCESS_GROUPS_ENTITLEMENTS_FILE_PATH", # The name of the environment variable
                                       description: "The path to the entitlement file which contains the keychain access groups", # a short description of this parameter
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a path to an entitlements file. ") unless value.include?(".entitlements")
                                         UI.user_error!("Could not find entitlements file") if !File.exist?(value) && !Helper.test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :identifiers,
                                       env_name: "FL_UPDATE_KEYCHAIN_ACCESS_GROUPS_IDENTIFIERS",
                                       description: "An Array of unique identifiers for the keychain access groups. Eg. ['your.keychain.access.groups.identifiers']",
                                       is_string: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("The parameter identifiers need to be an Array.") unless value.kind_of?(Array)
                                       end)
        ]
      end

      def self.output
        [
          ['KEYCHAIN_ACCESS_GROUPS', 'The new Keychain Access Groups']
        ]
      end

      def self.authors
        ["yutae"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'update_keychain_access_groups(
            entitlements_file: "/path/to/entitlements_file.entitlements",
            identifiers: ["your.keychain.access.groups.identifiers"]
          )'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
