require 'fastlane/action'

module Fastlane
  module Actions
    class MultiLineDescriptionAction < Action
      def self.run(params)
        # Do nothing
      end

      def self.description
        'This is ' \
        'multi line description.'
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
