module Fastlane
  module Actions
    class XctoolAction < Action
      def self.run(params)
        UI.important("Have you seen the new 'scan' tool to run tests? https://docs.fastlane.tools/actions/scan/")
        unless Helper.test?
          UI.user_error!("xctool not installed, please install using `brew install xctool`") if `which xctool`.length == 0
        end

        params = [] if params.kind_of?(FastlaneCore::Configuration)

        Actions.sh('xctool ' + params.join(' '))
      end

      def self.description
        "Run tests using xctool"
      end

      def self.details
        [
          "You can run any `xctool` action. This will require having [xctool](https://github.com/facebook/xctool) installed through [homebrew](http://brew.sh/).",
          "It is recommended to store the build configuration in the `.xctool-args` file.",
          "More information available on GitHub: https://docs.fastlane.tools/actions#xctool"
        ].join(' ')
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xctool :test',

          '# If you prefer to have the build configuration stored in the `Fastfile`:
          xctool :test, [
            "--workspace", "\'AwesomeApp.xcworkspace\'",
            "--scheme", "\'Schema Name\'",
            "--configuration", "Debug",
            "--sdk", "iphonesimulator",
            "--arch", "i386"
          ].join(" ")'
        ]
      end

      def self.category
        :testing
      end
    end
  end
end
