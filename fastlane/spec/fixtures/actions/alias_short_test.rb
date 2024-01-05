module Fastlane
  module Actions
    class AliasShortTestAction < Action
      def self.run(params)
        UI.important(params.join(","))
      end

      def self.alias_used(action_alias, params)
        params.replace("modified")
      end

      def self.aliases
        ["someshortalias"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
