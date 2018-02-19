module Fastlane
  module Actions
    # See: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcode-select.1.html
    #
    # DESCRIPTION
    #   xcode-select controls the location of the developer directory used by xcrun(1), xcodebuild(1), cc(1),
    #   and other Xcode and BSD development tools. This also controls the locations that are searched for  by
    #   man(1) for developer tool manpages.
    #
    # DEVELOPER_DIR
    #   Overrides the active developer directory. When DEVELOPER_DIR  is  set,  its  value  will  be  used
    #   instead of the system-wide active developer directory.
    #
    #   Note that for historical reason, the developer directory is considered to be the Developer content
    #   directory inside the Xcode application (for  example  /Applications/Xcode.app/Contents/Developer).
    #   You  can  set  the  environment variable to either the actual Developer contents directory, or the
    #   Xcode application directory -- the xcode-select provided  shims  will  automatically  convert  the
    #   environment variable into the full Developer content path.
    #
    class XcodeSelectAction < Action
      def self.run(params)
        params = nil unless params.kind_of?(Array)
        xcode_path = (params || []).first

        # Verify that a param was passed in
        UI.user_error!("Path to Xcode application required (e.g. `xcode_select(\"/Applications/Xcode.app\")`)") unless xcode_path.to_s.length > 0

        # Verify that a path to a directory was passed in
        UI.user_error!("Path '#{xcode_path}' doesn't exist") unless Dir.exist?(xcode_path)

        UI.message("Setting Xcode version to #{xcode_path} for all build steps")

        ENV["DEVELOPER_DIR"] = File.join(xcode_path, "/Contents/Developer")
      end

      def self.description
        "Change the xcode-path to use. Useful for beta versions of Xcode"
      end

      def self.details
        "Select and build with the Xcode installed at the provided path. Use the `xcversion` action if you want to select an Xcode based on a version specifier or you don't have known, stable paths as may happen in a CI environment."
      end

      def self.author
        "dtrenz"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xcode_select "/Applications/Xcode-8.3.2.app"'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
