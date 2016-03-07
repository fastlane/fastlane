module Fastlane
  module Actions
    module SharedValues
      APP_GROUP_IDENTIFIERS = :APP_GROUP_IDENTIFIERS
    end

    class UpdateAppGroupIdentifiersAction < Action
      require 'plist'

      def self.run(params)
        Helper.log.info "Entitlements File: #{params[:entitlements_file]}"
        Helper.log.info "New App Group Identifiers: #{params[:app_group_identifiers]}"

        entitlements_file = params[:entitlements_file]
        raise "Could not find entitlements file at path '#{entitlements_file}'".red unless File.exist?(entitlements_file)

        # parse entitlements
        result = Plist.parse_xml(entitlements_file)
        raise "Entitlements file at '#{entitlements_file}' cannot be parsed.".red unless result

        # get app group field
        app_group_field = result['com.apple.security.application-groups']
        raise 'No existing App group field specified. Please specify an App Group in the entitlements file.'.red unless app_group_field

        # set new app group identifiers
        Helper.log.info "Old App Group Identifiers: #{app_group_field}"
        result['com.apple.security.application-groups'] = params[:app_group_identifiers]

        # save entitlements file
        result.save_plist(entitlements_file)
        Helper.log.info "New App Group Identifiers set: #{result['com.apple.security.application-groups']}"

        Actions.lane_context[SharedValues::APP_GROUP_IDENTIFIERS] = result['com.apple.security.application-groups']
      end

      def self.description
        "This action changes the app group identifiers in the entitlements file"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :entitlements_file,
                                       env_name: "FL_UPDATE_APP_GROUP_IDENTIFIER_ENTITLEMENTS_FILE_PATH", # The name of the environment variable
                                       description: "The path to the entitlement file which contains the app group identifiers", # a short description of this parameter
                                       verify_block: proc do |value|
                                         raise "Please pass a path to an entitlements file. ".red unless value.include? ".entitlements"
                                         raise "Could not find entitlements file".red if !File.exist?(value) and !Helper.is_test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_group_identifiers,
                                       env_name: "FL_UPDATE_APP_GROUP_IDENTIFIER_APP_GROUP_IDENTIFIERS",
                                       description: "An Array of unique identifiers for the app groups. Eg. ['group.com.test.testapp']",
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "The parameter app_group_identifiers need to be an Array.".red unless value.kind_of? Array
                                       end)
        ]
      end

      def self.output
        ['APP_GROUP_IDENTIFIERS', 'The new App Group Identifiers']
      end

      def self.authors
        ["mathiasAichinger"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
