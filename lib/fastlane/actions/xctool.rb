module Fastlane
  module Actions
    class XctoolAction
      def self.run(params)
        raise "xctool not installed, please install using `brew install xctool`".red if `which xctool`.length == 0
        Actions.sh("xctool " + params.join(" "))
      end
    end
  end
end