module Fastlane
  module Actions
    class SayAction < Action
      def self.run(params)
        text = params.join(' ') if params.kind_of?(Array) # that's usually the case
        text = params if params.kind_of?(String)
        UI.user_error!("You can't call the `say` action as OneOff") unless text
        text = text.tr("'", '"')

        Actions.sh("say '#{text}'")
      end

      def self.description
        "This action speaks out loud the given text"
      end

      def self.is_supported?(platform)
        true
      end

      def self.author
        "KrauseFx"
      end

      def self.example_code
        [
          'say "I can speak"'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
