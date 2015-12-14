module Fastlane
  module Actions
    class PromptAction < Action
      def self.run(params)
        params[:text] += " (y/n)" if params[:boolean]
        Helper.log.info params[:text]

        return params[:ci_input] if Helper.is_ci?

        if params[:multi_line_end_keyword]
          # Multi line
          end_tag = params[:multi_line_end_keyword]
          Helper.log.info "Submit inputs using \"#{params[:multi_line_end_keyword]}\"".yellow
          user_input = STDIN.gets(end_tag).chomp.gsub(end_tag, "").strip
        else
          # Standard one line input
          user_input = STDIN.gets.chomp.strip while (user_input || "").length == 0
        end

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
          "When this is executed on a CI service, the passed `ci_input` value will be returned",
          "This action also supports multi-line inputs using the `multi_line_end_keyword` option."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :text,
                                       description: "The text that will be displayed to the user",
                                       default_value: "Please enter a text: "),
          FastlaneCore::ConfigItem.new(key: :ci_input,
                                       description: "The default text that will be used when being executed on a CI service",
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :boolean,
                                       description: "Is that a boolean question (yes/no)? This will add (y/n) at the end",
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :multi_line_end_keyword,
                                       description: "Enable multi-line inputs by providing an end text (e.g. 'END') which will stop the user input",
                                       optional: true,
                                       is_string: true)
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
