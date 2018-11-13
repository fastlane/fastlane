module Fastlane
  module Actions
    class SayAction < Action
      def self.run(params)
        text = params[:text]
        text = text.join(' ') if text.kind_of?(Array)
        text = text.tr("'", '"')

        if params[:mute]
          UI.message(text)
          return text
        else
          Actions.sh("say '#{text}'")
        end
      end

      def self.description
        "This action speaks the given text out loud"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :text,
                                       description: 'Text to be spoken out loud (as string or array of strings)',
                                       optional: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :mute,
                                       env_name: "SAY_MUTE",
                                       description: 'If say should be muted with text printed out',
                                       optional: false,
                                       is_string: false,
                                       type: Boolean,
                                       default_value: false)
        ]
      end

      def self.is_supported?(platform)
        true
      end

      def self.author
        "KrauseFx"
      end

      def self.example_code
        [
          'say("I can speak")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
