module Fastlane
  # Represents a command that is meant to signal the server to do something on the client's behalf
  # Examples are: :cancelFastlaneRune, and :done
  class ControlCommand
    attr_reader :command
    attr_reader :user_message
    attr_reader :reason

    def initialize(json: nil)
      @command = json['command'].to_sym
      @user_message = json['userMessage']
      @reason = json['reason'].to_sym if json['reason']
    end

    def cancel_signal?
      return @command == :cancelFastlaneRun
    end

    def done_signal?
      return @command == :done
    end
  end
end
