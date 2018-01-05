require 'fastlane/server/action_command.rb'
require 'fastlane/server/control_command.rb'
require 'json'

module Fastlane
  class CommandParser
    def self.parse(json: nil)
      command_json = JSON.parse(json)
      command_type = command_json['commandType'].to_sym
      command = command_json['command']

      case command_type
      when :action
        return ActionCommand.new(json: command)
      when :control
        return ControlCommand.new(json: command)
      end
    end
  end
end
