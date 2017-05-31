module Fastlane
  module Actions
    module SharedValues
    end

    class CheckSwiftVersionAction < Action
      def self.run(params)
        required_version = params[:version]
        selected_version = sh("swift -version")
        if selected_version.include?(required_version)
          UI.success("Selected Swift version is correct: #{selected_version}")
        else
          UI.message("Selected Swift version is not correct: #{selected_version}. You expected #{required_version}.")
          UI.message("To correct this, make sure you are using right Swift toolchain Or Xcode version")
          UI.user_error!("Selected Swift version doesn't match your requirement.\nExpected: #{required_version}\nActual: #{selected_version}\n")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Ensure the selected Swift version is correct"
      end


      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_ENSURE_SWIFT_VERSION",
                                       description: "Swift version to verify that is selected",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.authors
        ["Shashikant86"]
      end

      def self.example_code
        ['check_swift_version(version: "Apple Swift version 3.0.2")']
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
