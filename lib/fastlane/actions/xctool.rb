module Fastlane
  module Actions
    class XctoolAction < Action
      def self.run(params)
        unless Helper.test?
          raise 'xctool not installed, please install using `brew install xctool`'.red if `which xctool`.length == 0
        end

        Actions.sh('xctool ' + params.join(' '))
      end

      def self.description
        "Run tests using xctool"
      end

      def self.details
        [
          "It is recommended to store the build configuration in the `.xctool-args` file.",
          "More information available on GitHub: https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md#xctool"
        ].join(' ')
      end

      def self.author
        "KrauseFx"
      end
    end
  end
end
