module Fastlane
  # Call actions without triggering a full lane
  class OneOff
    def self.execute(args: nil)
      action_parameters = {}
      action_name = nil

      args.each do |current|
        if current.include? ":" # that's a key/value which we want to pass to the lane
          key, value = current.split(":", 2)
          raise "Please pass values like this: key:value" unless key.length > 0
          value = CommandLineHandler.convert_value(value)
          Helper.log.debug "Using #{key}: #{value}".yellow
          action_parameters[key.to_sym] = value
        else
          action_name ||= current
        end
      end

      raise "invalid syntax" unless action_name

      class_name = action_name.fastlane_class + 'Action'
      class_ref = nil
      begin
        class_ref = Fastlane::Actions.const_get(class_name)
      rescue NameError
        raise "Action not found"
      end

      r = Runner.new
      r.execute_action(action_name, class_ref, [action_parameters], custom_dir: '.')
    end
  end
end
