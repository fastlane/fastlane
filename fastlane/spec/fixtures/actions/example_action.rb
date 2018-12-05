module Fastlane
  module Actions
    class ExampleActionAction < Action
      def self.run(params)
        tmp = Dir.mktmpdir
        tmp_path = File.join(tmp, "example_action.txt")
        File.write(tmp_path, Time.now.to_i)
      end

      def self.is_supported?(platform)
        true
      end

      def self.available_options
      end
    end
  end
end
