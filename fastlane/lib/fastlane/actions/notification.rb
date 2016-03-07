module Fastlane
  module Actions
    class NotificationAction < Action
      def self.run(params)
        require 'terminal-notifier'

        if params[:subtitle] && params[:sound]
          TerminalNotifier.notify(params[:message],
                                  title: params[:title],
                                  subtitle: params[:subtitle],
                                  sound: params[:sound])
        elsif params[:subtitle]
          TerminalNotifier.notify(params[:message],
                                  title: params[:title],
                                  subtitle: params[:subtitle])
        elsif params[:sound]
          TerminalNotifier.notify(params[:message],
                                  title: params[:title],
                                  sound: params[:sound])
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
        ["champo", "cbowns", "KrauseFx", "amarcadet"]
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
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :sound,
                                       description: "The name of a sound to play when the notification appears (names are listed in Sound Preferences)",
                                       optional: true)
        ]
      end

      def self.is_supported?(platform)
        Helper.mac?
      end
    end
  end
end
