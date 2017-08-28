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
      command.args.each do |arg|
        parameter_map[arg.name.to_sym] = arg.value
      end

      run(action: action_name, parameter_map: parameter_map)
    end

    def run(action: nil, parameter_map: nil)
      class_ref = Actions.action_class_ref(action)
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

      runner.execute_action(action, class_ref, [parameter_map], custom_dir: '.')
    end
  end
end
