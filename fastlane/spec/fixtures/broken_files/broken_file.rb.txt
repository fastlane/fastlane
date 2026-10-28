module Fastlane
  module Actions
    class BrokenAction
      def run(params)
        # Missing comma
        puts {
          a: 123
          b: 345
        }
      end
    end
  end
end
