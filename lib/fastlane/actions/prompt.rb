module Fastlane
  module Actions
    class PromptAction < Action
      def self.run(params)
        params[:text] += " (y/n)" if params[:boolean]
        Helper.log.info params[:text]

        user_input = params[:ci_input] if Helper.is_ci?
        user_input ||= STDIN.gets.chomp.strip

        user_input = (user_input.downcase == 'y') if params[:boolean]

        return user_input
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Ask the user for a value or for confirmation"
      end

      def self.details
        [
          "You can use `prompt` to ask the user for a value or to just let the user confirm the next step",
          "When this is executed on a CI service, the passed `ci_input` value will be returned"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :text,
                                       description: "The text that will be displayed to the user"),
          FastlaneCore::ConfigItem.new(key: :ci_input,
                                       description: "The default text that will be used when being executed on a CI service",
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :boolean,
                                       description: "Is that a boolean question (yes/no)? This will add (y/n) at the end",
                                       default_value: false,
                                       is_string: false)
        ]
      end

      def self.output
        []
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end