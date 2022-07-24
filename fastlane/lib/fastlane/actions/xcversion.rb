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

      def self.read_xcode_version_file
        xcode_version_paths = Dir.glob(".xcode-version")

        if xcode_version_paths.first
          return File.read(xcode_version_paths.first).strip
        end

        return nil
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
                                       description: "The version of Xcode to select specified as a Gem::Version requirement string (e.g. '~> 7.1.0')",
                                       default_value: self.read_xcode_version_file,
                                       default_value_dynamic: true,
                                       verify_block: Helper::XcversionHelper::Verify.method(:requirement))
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xcversion(version: "8.1") # Selects Xcode 8.1.0',
          'xcversion(version: "~> 8.1.0") # Selects the latest installed version from the 8.1.x set'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
