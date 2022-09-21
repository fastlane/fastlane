module Fastlane
  module Actions
    class XcversionAction < Action
      def self.run(params)
        Actions.verify_gem!('xcode-install')

        version = params[:version]

        xcode = Helper::XcversionHelper.find_xcode(version)
        UI.user_error!("Cannot find an installed Xcode satisfying '#{version}'") if xcode.nil?

        UI.verbose("Found Xcode version #{xcode.version} at #{xcode.path} satisfying requirement #{version}")
        UI.message("Setting Xcode version to #{xcode.path} for all build steps")

        ENV["DEVELOPER_DIR"] = File.join(xcode.path, "/Contents/Developer")
      end

      def self.description
        "Select an Xcode to use by version specifier"
      end

      def self.details
        [
          "Finds and selects a version of an installed Xcode that best matches the provided [`Gem::Version` requirement specifier](http://www.rubydoc.info/github/rubygems/rubygems/Gem/Version)",
          "You can either manually provide a specific version using `version:` or you make use of the `.xcode-version` file."
        ].join("\n")
      end

      def self.authors
        ["oysta", "rogerluan"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_XCODE_VERSION",
                                       description: "The version of Xcode to select specified as a Gem::Version requirement string (e.g. '~> 7.1.0'). Defaults to the value specified in the .xcode-version file ",
                                       default_value: Helper::XcodesHelper.read_xcode_version_file,
                                       default_value_dynamic: true,
                                       verify_block: Helper::XcodesHelper::Verify.method(:requirement))
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xcversion(version: "8.1") # Selects Xcode 8.1.0',
          'xcversion(version: "~> 8.1.0") # Selects the latest installed version from the 8.1.x set',
          'xcversion # When missing, the version value defaults to the value specified in the .xcode-version file'
        ]
      end

      def self.category
        :deprecated
      end

      def self.deprecated_notes
        "The xcode-install gem, which this action depends on, has been sunset. Please migrate to [xcodes](https://docs.fastlane.tools/actions/xcodes). You can find a migration guide here: [xcpretty/xcode-install/MIGRATION.md](https://github.com/xcpretty/xcode-install/blob/master/MIGRATION.md)"
      end
    end
  end
end
