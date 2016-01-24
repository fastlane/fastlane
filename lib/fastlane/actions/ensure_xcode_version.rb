module Fastlane
  module Actions
    module SharedValues
      ENSURE_XCODE_VERSION_CUSTOM_VALUE = :ENSURE_XCODE_VERSION_CUSTOM_VALUE
    end

    class EnsureXcodeVersionAction < Action
      def self.run(params)
        required_version = params[:version]

        selected_version = sh "xcversion selected | head -1 | xargs echo -n"

        versions_match = selected_version == "Xcode #{required_version}"

        raise "Selected Xcode version doesn't match your requirement.\nExpected: Xcode #{required_version}\nActual: #{selected_version}\nTo correct this, use xcode_select." unless versions_match
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Ensure the selected Xcode version with xcode-select matches a value"
      end

      def self.details
        "If building your app requires a specific version of Xcode, you can invoke this command before using gym.\n
        For example, to ensure that a beta version is not accidentally selected to build, which would make uploading to TestFlight fail."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_ENSURE_XCODE_VERSION",
                                       description: "Xcode version to verify that is selected",
                                       is_string: true,
                                       default_value: false)
        ]
      end

      def self.output
        [
          ['FL_ENSURE_XCODE_VERSION', 'Xcode version to verify that is selected']
        ]
      end

      def self.return_value
      end

      def self.authors
        ["Javier Soto"]
      end

      def self.is_supported?(platform)
         [:ios, :mac].include?(platform)
      end
    end
  end
end
