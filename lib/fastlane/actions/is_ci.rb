module Fastlane
  module Actions
    class IsCiAction < Action
      def self.run(params)
        Helper.is_ci?
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Is the current run being executed on a CI system, like Jenkins or Travis"
      end

      def self.details
        [
          "The return value of this method is true if fastlane is currently executed on",
          "Travis, Jenkins, Circle or a similar CI service"
        ].join("\n")
      end

      def self.available_options
        []
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
