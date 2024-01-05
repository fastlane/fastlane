module Fastlane
  module Actions
    class DeprecatedActionAction < Action
      def self.run(params)
      end

      def self.is_supported?(platform)
        true
      end

      def self.category
        :deprecated
      end

      def self.deprecated_notes
        "This action is deprecated so do something else instead"
      end
    end
  end
end
