require 'fastlane/server/action_command.rb'
require 'fastlane/server/control_command.rb'
require 'json'

module Fastlane
  class CommandParser
    def self.parse(json: nil)
      if json.strip == "done"
        return intercept_old_done_command
      end

      command_json = JSON.parse(json)
      command_type_json = command_json['commandType']

      if command_type_json.nil?
        # Old Swift style (needs upgrade)
        return handle_old_style_action_command(command_json: command_json)
      else
        # New Swift command style
        return handle_new_style_commands(command_json: command_json)
      end
    end

    def self.handle_new_style_commands(command_json: nil)
      command_type = command_json['commandType'].to_sym
      command = command_json['command']

      case command_type
      when :action
        return ActionCommand.new(json: command)
      when :control
        return ControlCommand.new(json: command)
      end
    end

    def self.handle_old_style_action_command(command_json: nil)
      return ActionCommand.new(json: command_json)
    end

    def self.intercept_old_done_command
      return ControlCommand.new(json: '{"command":"done"}')
    end
  end
end
