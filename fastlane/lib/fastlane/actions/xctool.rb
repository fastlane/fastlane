module Fastlane
  module Actions
    class XctoolAction < Action
      def self.run(params)
        UI.important("Have you seen the new 'scan' tool to run tests? https://github.com/fastlane/fastlane/tree/master/scan")
        unless Helper.test?
          UI.user_error!("xctool not installed, please install using `brew install xctool`") if `which xctool`.length == 0
        end

        params = [] if params.kind_of? FastlaneCore::Configuration

        Actions.sh('xctool ' + params.join(' '))
      end

      def self.description
        "Run tests using xctool"
      end

      def self.details
        [
          "It is recommended to store the build configuration in the `.xctool-args` file.",
          "More information available on GitHub: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Actions.md#xctool"
        ].join(' ')
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
