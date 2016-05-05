module Fastlane
  module Actions
    class PwdAction < Action
      def self.run(params)
        return Dir.pwd
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
