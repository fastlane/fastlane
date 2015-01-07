module Fastlane
  module Actions
    class XctoolAction
      def self.run(params)
        Actions.sh("xctool " + params.join(" "))
      end
    end
  end
end