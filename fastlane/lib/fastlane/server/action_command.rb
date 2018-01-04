module Fastlane
  # Represents an argument to the ActionCommand
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

  # Represents a command that is meant to execute an Action on the client's behalf
  class ActionCommand
    attr_reader :command_id # always present
    attr_reader :args # always present
    attr_reader :method_name # always present
    attr_reader :class_name # only present when executing a class-method

    def initialize(json: nil)
      @method_name = json['methodName']
      @class_name = json['className']
      @command_id = json['commandID']

      args_json = json['args'] ||= []
      @args = args_json.map do |arg|
        Argument.new(json: arg)
      end
    end

    def cancel_signal?
      return @command_id == "cancelFastlaneRun"
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
  end
end
