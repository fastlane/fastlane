module Fastlane
  module Actions
    class ExampleActionAction < Action
      def self.run(params)
        File.write("/tmp/example_action.txt", Time.now.to_i)
      end

      def self.is_supported?(platform)
        true
      end

      def self.available_options
      end
    end
  end
end
