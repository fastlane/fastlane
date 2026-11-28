module Fastlane
  module Actions
    class EnsureXcodeVersionAction < Action
      def self.run(params)
        Actions.verify_gem!('xcode-install')
        required_version = params[:version]
        strict = params[:strict]

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

        if strict == true
          if selected_version == required_version
            success(selected_version)
          else
            error(selected_version, required_version)
          end
        else
          required_version_numbers = required_version.to_s.split(".")
          selected_version_numbers = selected_version.to_s.split(".")

          required_version_numbers.each_with_index do |required_version_number, index|
            selected_version_number = selected_version_numbers[index]
            next unless required_version_number != selected_version_number
            error(selected_version, required_version)
            break
          end

          success(selected_version)
        end
      end

      def self.success(selected_version)
        UI.success("Selected Xcode version is correct: #{selected_version}")
      end

      def self.error(selected_version, required_version)
        UI.message("Selected Xcode version is not correct: #{selected_version}. You expected #{required_version}.")
        UI.message("To correct this, use: `xcode_select(version: #{required_version})`.")

        UI.user_error!("Selected Xcode version doesn't match your requirement.\nExpected: Xcode #{required_version}\nActual: Xcode #{selected_version}\n")
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
          "You can either manually provide a specific version using `version:` or you make use of the `.xcode-version` file.",
          "Using the `strict` parameter, you can either verify the full set of version numbers strictly (i.e. `11.3.1`) or only a subset of them (i.e. `11.3` or `11`)."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_ENSURE_XCODE_VERSION",
                                       description: "Xcode version to verify that is selected",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :strict,
                                       description: "Should the version be verified strictly (all 3 version numbers), or matching only the given version numbers (i.e. `11.3` == `11.3.x`)",
                                       type: Boolean,
                                       default_value: true)
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
          'ensure_xcode_version(version: "12.5")'
        ]
      end

      def self.category
        :building
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.deprecated_notes
        "The xcode-install gem, which this action depends on, has been sunset. Please migrate to [xcodes](https://docs.fastlane.tools/actions/xcodes). You can find a migration guide here: [xcpretty/xcode-install/MIGRATION.md](https://github.com/xcpretty/xcode-install/blob/master/MIGRATION.md)"
      end
    end
  end
end
