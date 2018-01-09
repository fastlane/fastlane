module Fastlane
  module Actions
    module SharedValues
      UPDATE_ICLOUD_CONTAINER_IDENTIFIERS = :UPDATE_ICLOUD_CONTAINER_IDENTIFIERS
    end

    class UpdateIcloudContainerIdentifiersAction < Action
      require 'plist'

      def self.run(params)
        entitlements_file = params[:entitlements_file]
        UI.message("Entitlements File: #{entitlements_file}")

        # parse entitlements
        result = Plist.parse_xml(entitlements_file)
        UI.error("Entitlements file at '#{entitlements_file}' cannot be parsed.") unless result

        # get iCloud container field
        icloud_container_key = 'com.apple.developer.icloud-container-identifiers'
        icloud_container_value = result[icloud_container_key]
        UI.error("No existing iCloud container field specified. Please specify an iCloud container in the entitlements file.") unless icloud_container_value

        # get uniquity container field
        ubiquity_container_key = 'com.apple.developer.ubiquity-container-identifiers'
        ubiquity_container_value = result[ubiquity_container_key]
        UI.error("No existing ubiquity container field specified. Please specify an ubiquity container in the entitlements file.") unless ubiquity_container_value

        # set iCloud container identifiers
        result[icloud_container_key] = params[:icloud_container_identifiers]
        result[ubiquity_container_key] = params[:icloud_container_identifiers]

        # save entitlements file
        result.save_plist(entitlements_file)

        UI.message("Old iCloud Container Identifiers: #{icloud_container_value}")
        UI.message("Old Ubiquity Container Identifiers: #{ubiquity_container_value}")

        UI.success("New iCloud Container Identifiers set: #{result[icloud_container_key]}")
        UI.success("New Ubiquity Container Identifiers set: #{result[ubiquity_container_key]}")

        Actions.lane_context[SharedValues::UPDATE_ICLOUD_CONTAINER_IDENTIFIERS] = result[icloud_container_key]
      end

      def self.description
        "This action changes the iCloud container identifiers in the entitlements file"
      end

      def self.details
        "Updates the iCloud Container Identifiers in the given Entitlements file, so you can use different iCloud containers for different builds like Adhoc, App Store, etc."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :entitlements_file,
                                       env_name: "FL_UPDATE_ICLOUD_CONTAINER_IDENTIFIERS_ENTITLEMENTS_FILE_PATH",
                                       description: "The path to the entitlement file which contains the iCloud container identifiers",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a path to an entitlements file. ") unless value.include?(".entitlements")
                                         UI.user_error!("Could not find entitlements file") if !File.exist?(value) and !Helper.is_test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :icloud_container_identifiers,
                                       env_name: "FL_UPDATE_ICLOUD_CONTAINER_IDENTIFIERS_IDENTIFIERS",
                                       description: "An Array of unique identifiers for the iCloud containers. Eg. ['iCloud.com.test.testapp']",
                                       is_string: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("The parameter icloud_container_identifiers needs to be an Array.") unless value.kind_of?(Array)
                                       end)
        ]
      end

      def self.output
        ['UPDATE_ICLOUD_CONTAINER_IDENTIFIERS', 'The new iCloud Container Identifiers']
      end

      def self.authors
        ["JamesKuang"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'update_icloud_container_identifiers(
            entitlements_file: "/path/to/entitlements_file.entitlements",
            icloud_container_identifiers: ["iCloud.com.companyname.appname"]
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
