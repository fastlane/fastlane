require 'json'

module Fastlane
  class Argument
    def initialize(json: nil)
      @name = json['name']
      @value = json['value']
    end

    def is_named
      return @name.to_s.length > 0
    end

    def inspect
      if is_named
        return "named argument: #{name}, value: #{value}"
      else
        return "unnamed argument value: #{value}"
      end
    end

    attr_reader :name
    attr_reader :value
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

      # rubocop:disable Security/Eval
      return eval(class_name)
      # rubocop:enable Security/Eval
    end

    def is_class_method_command
      return class_name.to_s.length > 0
    end

    attr_reader :command_id # always present
    attr_reader :args # always present
    attr_reader :method_name # always present
    attr_reader :class_name # only present when executing a class-method
  end
end
