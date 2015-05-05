module Fastlane
  module Actions
    class ExampleActionAction
      def self.run(params)
        File.write("/tmp/example_action.txt", Time.now.to_i)
      end

      def self.available_options

      end
    end
  end
end