require 'json'

module Fastlane
  class Argument
    def initialize(json: nil)
      @name = json['name']
      @value = json['value']
      @value_type = json['value_type']
    end

    def is_named
      return @name.to_s.length > 0
    end

    def inspect
      if is_named
        return "named argument: #{name}, value: #{value}, type: #{value_type}"
      else
        return "unnamed argument value: #{value}, type: #{value_type}"
      end
    end

    attr_reader :name
    attr_reader :value
    attr_reader :value_type
  end

  class Command
    def initialize(json: nil)
      command_json = JSON.parse(json)
      @method_name = command_json['methodName']
      @class_name = command_json['className']
      @command_id = command_json['commandID']

      args_json = command_json['args'] ||= []
      @args = args_json.map do |arg|
        Argument.new(json: arg)
      end
    end

    def target_class
      unless class_name
        return nil
      end

      return Fastlane::Actions.const_get(class_name)
    end

    def is_class_method_command
      return class_name.to_s.length > 0
    end

    attr_reader :command_id # always present
    attr_reader :args # always present
    attr_reader :method_name # always present
    attr_reader :class_name # only present when executing a class-method
  end

  class CommandReturn
    attr_reader :return_value
    attr_reader :return_value_type
    attr_reader :closure_argument_value

    def initialize(return_value: nil, return_value_type: nil, closure_argument_value: nil)
      @return_value = return_value
      @closure_argument_value = closure_argument_value
      @return_value_type = return_value_type
    end
  end
end
