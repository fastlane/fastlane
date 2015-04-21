module Fastlane
  module Actions
    class ExampleActionAction
      def self.run(_params)
        File.write("/tmp/example_action.txt", Time.now.to_i)
      end
    end
  end
end
