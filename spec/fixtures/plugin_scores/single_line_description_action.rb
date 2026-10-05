require 'fastlane/action'

module Fastlane
  module Actions
    class SingleLineDescriptionAction < Action
      def self.run(params)
        # Do nothing
      end

      def self.description
        "This is single line description."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :hello,
            description: 'A hello value',
            optional: true
          )
        ]
      end
    end
  end
end
