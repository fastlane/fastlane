module Fastlane
  module Actions
    module SharedValues
      ENSURE_XCODE_VERSION_CUSTOM_VALUE = :ENSURE_XCODE_VERSION_CUSTOM_VALUE
    end

    class EnsureXcodeVersionAction < Action
      def self.run(params)
        Actions.verify_gem!('xcode-install')
        required_version = params[:version]
        match_version = params[:match]
        selected_version = sh("xcversion selected").match(/^Xcode (.*)$/)[1]

        if required_version
          if selected_version == required_version
            UI.success("Selected Xcode version is correct: #{selected_version}")
          else
            UI.message("Selected Xcode version is not correct: #{selected_version}. You expected #{required_version}.")
            UI.message("To correct this, use: `xcode_select(version: #{required_version})`.")

            UI.user_error!("Selected Xcode version doesn't match your requirement.\nExpected: Xcode #{required_version}\nActual: #{selected_version}\n")
          end
        elsif match_version
          if selected_version =~ /^#{match_version}/
            UI.success("Selected Xcode version: #{selected_version}, match: #{match_version}")
          else
            UI.success("Selected Xcode version: #{selected_version}, doesn't match: #{match_version}")
            UI.user_error!("Selected Xcode version doesn't match your requirement.\nExpected: Xcode #{match_version}\nActual: #{selected_version}\n")
          end
        else
          UI.user_error!("You have to either pass a 'required_version' or a 'match_version' to the action")
        end
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
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :match,
                                      env_name: "FL_ENSURE_XCODE_VERSION_MATCH",
                                      description: "Regular expression matching selected Xcode version",
                                      is_string: true,
                                      optional: true)
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
        ["JaviSoto"]
      end

      def self.example_code
        [
          'ensure_xcode_version(version: "7.2")',
          'ensure_xcode_version(match: "8")'
        ]
      end

      def self.category
        :building
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
