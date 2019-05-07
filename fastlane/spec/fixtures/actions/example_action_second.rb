module Fastlane
  module Actions
    class ExampleActionSecondAction
      def self.run(params)
        puts('running')
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
