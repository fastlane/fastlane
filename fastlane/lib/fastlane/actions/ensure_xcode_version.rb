module Fastlane
  module Actions
    class EnsureXcodeVersionAction < Action
      def self.run(params)
        Actions.verify_gem!('xcode-install')
        required_version = params[:version]

        if required_version.to_s.length == 0
          # The user didn't provide an Xcode version, let's see
          # if the current project has a `.xcode-version` file
          #
          # The code below can be improved to also consider
          # the directory of the Xcode project
          xcode_version_paths = Dir.glob(".xcode-version")

          if xcode_version_paths.first
            UI.verbose("Loading required version from #{xcode_version_paths.first}")
            required_version = File.read(xcode_version_paths.first).strip
          else
            UI.user_error!("No version: provided when calling the `ensure_xcode_version` action")
          end
        end

        selected_version = sh("xcversion selected").match(/^Xcode (.*)$/)[1]

        begin
          selected_version = Gem::Version.new(selected_version)
          required_version = Gem::Version.new(required_version)
        rescue ArgumentError => ex
          UI.user_error!("Invalid version number provided, make sure it's valid: #{ex}")
        end

        if selected_version == required_version
          UI.success("Selected Xcode version is correct: #{selected_version}")
        else
          UI.message("Selected Xcode version is not correct: #{selected_version}. You expected #{required_version}.")
          UI.message("To correct this, use: `xcode_select(version: #{required_version})`.")

          UI.user_error!("Selected Xcode version doesn't match your requirement.\nExpected: Xcode #{required_version}\nActual: Xcode #{selected_version}\n")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Ensure the right version of Xcode is used"
      end

      def self.details
        [
          "If building your app requires a specific version of Xcode, you can invoke this command before using gym.",
          "For example, to ensure that a beta version of Xcode is not accidentally selected to build, which would make uploading to TestFlight fail.",
          "You can either manually provide a specific version using `version: ` or you make use of the `.xcode-version` file."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_ENSURE_XCODE_VERSION",
                                       description: "Xcode version to verify that is selected",
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
        ["JaviSoto", "KrauseFx"]
      end

      def self.example_code
        [
          'ensure_xcode_version(version: "7.2")'
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
