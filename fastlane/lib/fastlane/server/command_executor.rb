require 'fastlane/server/command.rb'

module Fastlane
  class CommandExecutor
    def execute(command: nil, target_object: nil)
      not_implemented(__method__)
    end
  end

  class GenericCommandExecuter < CommandExecutor
    def execute(command: nil, target_object: nil)
      method_name = command.method_name
      args = command.args
      transformed_arg_list = []

      # only a single closure is supported
      closure_argument_value = nil

      args.each do |arg|
        arg_value = arg.value
        if arg.value_type.to_sym == :string_closure
          closure = proc { |string_value| closure_argument_value = string_value }
          arg_value = closure
        end

        if arg.is_named
          transformed_arg_list << { arg.name.to_sym => arg_value }
        else
          transformed_arg_list << arg_value
        end
      end

      unless target_object
        # if we don't pass in a target_object, we need to assume we're executing a class-level method
        # so try and get the target_class from the command
        target_object = command.target_class
      end

      return_value = target_object.public_send(method_name, *transformed_arg_list)

      command_return = CommandReturn.new(return_value: return_value, closure_argument_value: closure_argument_value)
      return command_return
    end
  end
end
