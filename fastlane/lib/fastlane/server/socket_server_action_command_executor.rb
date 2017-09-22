require 'fastlane/server/command.rb'
require 'fastlane/server/command_executor.rb'

module Fastlane
  class SocketServerActionCommandExecutor < CommandExecutor
    attr_accessor :runner

    def initialize
      Fastlane.load_actions
      @runner = Runner.new
    end

    def execute(command: nil, target_object: nil)
      action_name = command.method_name
      parameter_map = {}
      closure_argument_value = nil

      command.args.each do |arg|
        arg_value = arg.value
        if arg.value_type.to_s.to_sym == :string_closure
          closure = proc { |string_value| closure_argument_value = string_value }
          arg_value = closure
        end
        parameter_map[arg.name.to_sym] = arg_value
      end

      action_class_ref = class_ref_for_action(named: action_name)
      action_return = run(action_named: action_name, action_class_ref: action_class_ref, parameter_map: parameter_map)

      command_return = CommandReturn.new(
        return_value: action_return,
        return_value_type: action_class_ref.return_type,
        closure_argument_value: closure_argument_value
      )
      return command_return
    end

    def class_ref_for_action(named: nil)
      class_ref = Actions.action_class_ref(named)
      unless class_ref
        if Fastlane::Actions.formerly_bundled_actions.include?(action)
          # This was a formerly bundled action which is now a plugin.
          UI.verbose(caller.join("\n"))
          UI.user_error!("The action '#{action}' is no longer bundled with fastlane. You can install it using `fastlane add_plugin #{action}`")
        else
          Fastlane::ActionsList.print_suggestions(action)
          UI.user_error!("Action '#{action}' not available, run `fastlane actions` to get a full list")
        end
      end

      return class_ref
    end

    def run(action_named: nil, action_class_ref: nil, parameter_map: nil)
      action_return = runner.execute_action(action_named, action_class_ref, [parameter_map], custom_dir: '.')
      return action_return
    end
  end
end
