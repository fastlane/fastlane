module Fastlane
  module Actions
    class NotifyAction
      def self.run(params)
        require 'terminal-notifier'

        text = params.join(' ')
        TerminalNotifier.notify(text,
                                :title => 'Fastlane',
                               )
      end
    end
  end
end
