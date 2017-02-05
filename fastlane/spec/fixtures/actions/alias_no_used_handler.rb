module Fastlane
  module Actions
    class AliasNoUsedHandlerAction < Action
      def self.run(params)
        UI.important("run")
      end

      def self.aliases
        ["alias_no_used_handler_sample_alias"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
