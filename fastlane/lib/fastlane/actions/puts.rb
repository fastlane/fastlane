module Fastlane
  module Actions
    class PutsAction < Action
      def self.run(params)
        UI.message(params.join(' '))
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Prints out the given text"
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.alias_used(action_alias, params)
        UI.important("#{action_alias} called, please use 'puts' instead!")
      end

      def self.aliases
        ["println", "echo"]
      end

      # We don't want to show this as step
      def self.step_text
        nil
      end

      def self.example_code
        [
          'puts "Hi there"'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
