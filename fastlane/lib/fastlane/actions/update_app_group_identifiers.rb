module Fastlane
  module Actions
    module SharedValues
      APP_GROUP_IDENTIFIERS = :APP_GROUP_IDENTIFIERS
    end

    class UpdateAppGroupIdentifiersAction < Action
      require 'plist'

      def self.run(params)
        UI.message("Entitlements File: #{params[:entitlements_file]}")
        UI.message("New App Group Identifiers: #{params[:app_group_identifiers]}")

        entitlements_file = params[:entitlements_file]
        UI.user_error!("Could not find entitlements file at path '#{entitlements_file}'") unless File.exist?(entitlements_file)

        # parse entitlements
        result = Plist.parse_xml(entitlements_file)
        UI.user_error!("Entitlements file at '#{entitlements_file}' cannot be parsed.") unless result

        # get app group field
        app_group_field = result['com.apple.security.application-groups']
        UI.user_error!("No existing App group field specified. Please specify an App Group in the entitlements file.") unless app_group_field

        # set new app group identifiers
        UI.message("Old App Group Identifiers: #{app_group_field}")
        result['com.apple.security.application-groups'] = params[:app_group_identifiers]

        # save entitlements file
        result.save_plist(entitlements_file)
        UI.message("New App Group Identifiers set: #{result['com.apple.security.application-groups']}")

        Actions.lane_context[SharedValues::APP_GROUP_IDENTIFIERS] = result['com.apple.security.application-groups']
      end

      def self.description
        "This action changes the app group identifiers in the entitlements file"
      end

      def self.details
        "Updates the App Group Identifiers in the given Entitlements file, so you can have app groups for the app store build and app groups for an enterprise build."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :entitlements_file,
                                       env_name: "FL_UPDATE_APP_GROUP_IDENTIFIER_ENTITLEMENTS_FILE_PATH", # The name of the environment variable
                                       description: "The path to the entitlement file which contains the app group identifiers", # a short description of this parameter
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a path to an entitlements file. ") unless value.include?(".entitlements")
                                         UI.user_error!("Could not find entitlements file") if !File.exist?(value) && !Helper.test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_group_identifiers,
                                       env_name: "FL_UPDATE_APP_GROUP_IDENTIFIER_APP_GROUP_IDENTIFIERS",
                                       description: "An Array of unique identifiers for the app groups. Eg. ['group.com.test.testapp']",
                                       type: Array)
        ]
      end

      def self.output
        [
          ['APP_GROUP_IDENTIFIERS', 'The new App Group Identifiers']
        ]
      end

      def self.authors
        ["mathiasAichinger"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'update_app_group_identifiers(
            entitlements_file: "/path/to/entitlements_file.entitlements",
            app_group_identifiers: ["group.your.app.group.identifier"]
          )'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
