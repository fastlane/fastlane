module Fastlane
  module Actions
    class NotificationAction < Action
      def self.run(params)
        require 'terminal-notifier'

        if params[:subtitle]
          TerminalNotifier.notify(params[:message],
                                  title: params[:title],
                               subtitle: params[:subtitle])
        else
          # It should look nice without a subtitle too
          TerminalNotifier.notify(params[:message],
                                  title: params[:title])
        end
      end

      def self.description
        "Display a Mac OS X notification with custom message and title"
      end

      def self.author
        ["champo", "cbowns", "KrauseFx"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :title,
                                       description: "The title to display in the notification",
                                       default_value: 'fastlane'),
          FastlaneCore::ConfigItem.new(key: :subtitle,
                                       description: "A subtitle to display in the notification",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :message,
                                       description: "The message to display in the notification",
                                       optional: false)
        ]
      end

      def self.is_supported?(platform)
        Helper.mac?
      end
    end
  end
end
