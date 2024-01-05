module Fastlane
  # Call actions without triggering a full lane
  class OneOff
    def self.execute(args: nil)
      action_parameters = {}
      action_name = nil

      args.each do |current|
        if current.include?(":") # that's a key/value which we want to pass to the lane
          key, value = current.split(":", 2)
          UI.user_error!("Please pass values like this: key:value") unless key.length > 0
          value = CommandLineHandler.convert_value(value)
          UI.verbose("Using #{key}: #{value}")
          action_parameters[key.to_sym] = value
        else
          action_name ||= current
        end
      end

      UI.crash!("invalid syntax") unless action_name

      run(action: action_name,
          parameters: action_parameters)
    end

    def self.run(action: nil, parameters: nil)
      Fastlane.load_actions

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

      r = Runner.new
      r.execute_action(action, class_ref, [parameters], custom_dir: '.')
    end
  end
end
