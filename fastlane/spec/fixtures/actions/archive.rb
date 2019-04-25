module Fastlane
  module Actions
    class ArchiveAction < Action
      def self.run(params)
        puts('yes')
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
