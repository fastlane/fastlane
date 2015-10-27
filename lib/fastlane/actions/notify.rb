module Fastlane
  module Actions
    class NotifyAction < Action
      def self.run(params)
        require 'terminal-notifier'

        message  = params[:message]
        title    = params[:title] || 'fastlane'
        subtitle = params[:subtitle] if params[:subtitle]

        if subtitle
          TerminalNotifier.notify(message, title: title, subtitle: subtitle)
        else
          TerminalNotifier.notify(message, title: title)
        end
      end

      def self.description
        "Shows a Mac OS X notification"
      end

      def self.author
        "champo, cbowns"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :message,
                                       description: "The message to display in the notification",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :title,
                                       description: "The title to display in the notification",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :subtitle,
                                       description: "A subtitle to display in the notification",
                                       optional: true),
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
