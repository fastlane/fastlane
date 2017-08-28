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
      args.each do |arg|
        if arg.is_named
          transformed_arg_list << { arg.name.to_sym => arg.value }
        else
          transformed_arg_list << arg.value
        end
      end

      unless target_object
        # if we don't pass in a target_object, we need to assume we're executing a class-level method
        # so try and get the target_class from the command
        target_object = command.target_class
      end

      return target_object.public_send(method_name, *transformed_arg_list)
    end
  end
end
