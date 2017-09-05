module Fastlane
  class SwiftFunction
    attr_accessor :function_name
    attr_accessor :return_type
    attr_accessor :param_names
    attr_accessor :param_descriptions
    attr_accessor :param_default_values
    attr_accessor :param_optionality_values
    attr_accessor :param_type_overrides
    attr_accessor :reserved_words
    attr_accessor :default_values_to_ignore

    def initialize(action_name: nil, keys: nil, key_descriptions: nil, key_default_values: nil, key_optionality_values: nil, key_type_overrides: nil, return_type: nil)
      @function_name = action_name
      @param_names = keys
      @param_descriptions = key_descriptions
      @param_default_values = key_default_values
      @param_optionality_values = key_optionality_values
      @return_type = return_type
      @param_type_overrides = key_type_overrides

      # rubocop:disable LineLength
      # class instance?
      @reserved_words = %w[associativity break case catch class continue convenience default deinit didSet do else enum extension fallthrough false final for func get guard if in infix init inout internal lazy let mutating nil operator override postfix precedence prefix private public repeat required return self set static struct subscript super switch throws true try var weak where while willSet].to_set
      # rubocop:enable LineLength

      @default_values_to_ignore = {
        "cert" => ["keychain_path"].to_set,
        "set_github_release" => ["api_token"].to_set,
        "github_api" => ["api_token"].to_set,
        "create_pull_request" => ["api_token", "head"].to_set,
        "commit_github_file" => ["api_token"].to_set,
        "verify_xcode" => ["xcode_path"].to_set,
        "produce" => ["sku"].to_set
      }
    end

    def ignore_default_value?(function_name: nil, param_name: nil)
      action_set = @default_values_to_ignore[function_name]
      unless action_set
        return false
      end

      return action_set.include?(param_name)
    end

    def sanitize_reserved_word(word: nil)
      unless @reserved_words.include?(word)
        return word
      end
      return word + "🚀"
    end

    def return_declaration
      expected_type = swift_type_for_return_type
      unless expected_type.to_s.length > 0
        return ""
      end

      return " -> #{expected_type}"
    end

    def swift_type_for_return_type
      unless @return_type
        return ""
      end

      case @return_type
      when :string
        return "String"
      when :array_of_strings
        return "[String]"
      when :hash_of_strings
        return "[String : String]"
      when :bool
        return "Bool"
      when :int
        return "Int"
      else
        return ""
      end
    end

    def camel_case_lower(string: nil)
      string.split('_').inject([]) { |buffer, e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end

    def determine_type_from_override(type_override: nil)
      if type_override == Array
        return "[String]"
      elsif type_override == Hash
        return "[String : String]"
      elsif type_override == Integer
        return "Int"
      else
        return type_override
      end
    end

    def override_default_value_if_not_correct_type(param_type: nil, default_value: nil)
      # \[\w*\]
      return "[]" if param_type == "[String]" && default_value == ""

      return default_value
    end

    def parameters
      unless @param_names
        return ""
      end

      param_names_and_types = @param_names.zip(param_default_values, param_optionality_values, param_type_overrides).map do |param, default_value, optional, param_type_override|
        unless param_type_override.nil?
          type = determine_type_from_override(type_override: param_type_override)
        end
        type ||= "String"

        # some default values should be ignored during Swift generation because they use our local environment to
        # deduce what values should be used
        default_value = nil if ignore_default_value?(function_name: @function_name, param_name: param)

        optional_specifier = ""
        # if we are optional and don't have a default value, we'll need to use ?
        optional_specifier = "?" if optional && default_value.nil?

        # If we have a default value of true or false, we can infer it is a Bool
        if default_value.class == FalseClass
          type = "Bool"
        elsif default_value.class == TrueClass
          type = "Bool"
        elsif default_value.kind_of?(Array)
          type = "[String]"
        end

        # sometimes we get to the point where we have a default value but its type is wrong
        # so we need to correct that because [String] = "" is not valid swift
        default_value = override_default_value_if_not_correct_type(param_type: type, default_value: default_value)

        unless default_value.nil?
          if type == "Bool" || type == "[String]" || type == "Int"
            default_value = " = #{default_value}"
          elsif type == "[String : String]"
            # we can't handle default values for Hashes, yet
            default_value = ""
          else
            default_value = " = \"#{default_value}\""
          end
        end

        # if we don't have a default value, but the param is options, just set a default value to nil
        if optional
          default_value ||= " = nil"
        end

        # erase the default value from the swift param string since it's nil because
        # it means we don't have a default value nor optional value so we must get one
        default_value ||= ""

        param = camel_case_lower(string: param)
        param = sanitize_reserved_word(word: param)
        "#{param}: #{type}#{optional_specifier}#{default_value}"
      end

      return param_names_and_types.join(", ")
    end

    def swift_code
      function_name = camel_case_lower(string: self.function_name)
      return "func #{function_name}(#{self.parameters})#{self.return_declaration} {\n#{self.implementation}\n}"
    end

    def build_argument_list
      unless @param_names
        return "[]" # return empty list for argument
      end

      argument_object_strings = @param_names.map do |name|
        sanitized_name = camel_case_lower(string: name)
        sanitized_name = sanitize_reserved_word(word: sanitized_name)
        "RubyCommand.Argument(name: \"#{name}\", value: #{sanitized_name})"
      end
      argument_object_strings = argument_object_strings.join(", ")
      argument_object_strings = "[#{argument_object_strings}]" # turn into swift array
      return argument_object_strings
    end

    def return_statement
      expected_type = swift_type_for_return_type

      return_string = "_ = "
      as_string = ""
      if expected_type.length > 0
        return_string = "return "
        as_string = " as! #{expected_type}"

      end
      return "#{return_string}runner.executeCommand(command)#{as_string}"
    end

    def implementation
      args = build_argument_list

      implm = "  let command = RubyCommand(commandID: \"\", methodName: \"#{@function_name}\", className: nil, args: #{args})\n"
      return implm + "  #{return_statement}"
    end
  end

  class ToolSwiftFunction < SwiftFunction
    def get_type(param: nil, default_value: nil, optional: nil)
      type = "String"
      optional_specifier = ""

      # if we are optional and don't have a default value, we'll need to use ?
      optional_specifier = "?" if optional && default_value.nil?

      # If we have a default value of true or false, we can infer it is a Bool
      if default_value.class == FalseClass
        type = "Bool"
      elsif default_value.class == TrueClass
        type = "Bool"
      end

      unless default_value.nil?
        if default_value.kind_of?(Array)
          type = "[String]"
        end
      end
      return "#{type}#{optional_specifier}"
    end

    def protocol_name
      function_name = camel_case_lower(string: self.function_name)
      return function_name.capitalize + "fileProtocol"
    end

    def class_name
      function_name = camel_case_lower(string: self.function_name)
      return function_name.capitalize + "file"
    end

    def swift_vars
      unless @param_names
        return []
      end

      swift_vars = @param_names.zip(param_default_values, param_optionality_values).map do |param, default_value, optional|
        type = get_type(param: param, default_value: default_value, optional: optional)
        param = camel_case_lower(string: param)
        param = sanitize_reserved_word(word: param)
        static_var_for_parameter_name = param
        "  var #{static_var_for_parameter_name}: #{type} { get }"
      end

      return swift_vars
    end

    def swift_default_implementations
      unless @param_names
        return []
      end

      swift_implementations = @param_names.zip(param_default_values, param_optionality_values).map do |param, default_value, optional|
        type = get_type(param: param, default_value: default_value, optional: optional)
        param = camel_case_lower(string: param)
        param = sanitize_reserved_word(word: param)
        static_var_for_parameter_name = param

        unless default_value.nil?
          if type == "Bool" || default_value.kind_of?(Array)
            default_value = default_value.to_s
          else
            default_value = "\"#{default_value}\""
          end
        end

        # if we don't have a default value, but the param is options, just set a default value to nil
        if optional
          default_value ||= "nil"
        end

        # if we don't have a default value still, we need to assign them based on type
        if type == "String"
          default_value ||= "\"\""
        end

        if type == "Bool"
          default_value ||= "false"
        end

        if type == "[String]"
          default_value ||= "[]"
        end

        "  var #{static_var_for_parameter_name}: #{type} { return #{default_value} }"
      end

      return swift_implementations
    end

    def parameters
      unless @param_names
        return ""
      end

      param_names_and_types = @param_names.zip(param_default_values, param_optionality_values).map do |param, default_value, optional|
        type = get_type(param: param, default_value: default_value, optional: optional)
        param = camel_case_lower(string: param)
        param = sanitize_reserved_word(word: param)
        static_var_for_parameter_name = param

        "#{param}: #{type} = #{self.class_name.downcase}.#{static_var_for_parameter_name}"
      end

      return param_names_and_types.join(", ")
    end
  end
end