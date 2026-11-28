module Fastlane
  module Actions
    class IsCiAction < Action
      def self.run(params)
        Helper.ci?
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Is the current run being executed on a CI system, like Jenkins or Travis"
      end

      def self.details
        "The return value of this method is true if fastlane is currently executed on Travis, Jenkins, Circle or a similar CI service"
      end

      def self.available_options
        []
      end

      def self.return_type
        :bool
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'if is_ci
            puts "I\'m a computer"
          else
            say "Hi Human!"
          end'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
