module Fastlane
  module Actions
    class AliasTestAction < Action
      def self.run(params)
        UI.important(params[:example])
      end

      def self.alias_used(action_alias, params)
        params[:example] = "modified"
      end

      def self.aliases
        ["somealias"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :example,
                                     short_option: "-e",
                                     description: "Example Param",
                                     optional: true,
                                     default_value: "Test String",
                                     is_string: true),
          FastlaneCore::ConfigItem.new(key: :example_two,
                                     short_option: "-t",
                                     description: "Example Param",
                                     optional: true,
                                     default_value: "Test String",
                                     is_string: true)
        ]
      end
    end
  end
end
