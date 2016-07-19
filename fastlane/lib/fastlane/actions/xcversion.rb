module Fastlane
  module Actions
    class XcversionAction < Action
      def self.run(params)
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

      def self.author
        "oysta"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_XCODE_VERSION",
                                       description: "The version of Xcode to select specified as a Gem::Version requirement string (e.g. '~> 7.1.0')",
                                       optional: false,
                                       verify_block: Helper::XcversionHelper::Verify.method(:requirement))
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
