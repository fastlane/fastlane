module Fastlane
  class SwiftFunction
    attr_accessor :function_name
    attr_accessor :return_type
    attr_accessor :param_names
    attr_accessor :param_descriptions
    attr_accessor :param_default_values
    attr_accessor :param_optionality_values
    attr_accessor :reserved_words

    def initialize(action_name: nil, keys: nil, key_descriptions: nil, key_default_values: nil, key_optionality_values: nil, return_type: nil)
      @function_name = action_name
      @param_names = keys
      @param_descriptions = key_descriptions
      @param_default_values = key_default_values
      @param_optionality_values = key_optionality_values
      @return_type = return_type

      @reserved_words = %w[associativity break case catch class continue convenience default deinit didSet do else enum extension fallthrough false final for func get guard if in infix init inout internal lazy let mutating nil operator override postfix precedence prefix private public repeat required return self set static struct subscript super switch throws true try var weak where while willSet].to_set
      @options_to_ignore = {
        "cocoapods" => ["error_callback"],
        "sh" => ["error_calback"]
      }
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

    def parameters
      unless @param_names
        return ""
      end

      param_names_and_types = @param_names.zip(param_default_values, param_optionality_values).map do |param, default_value, optional|
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
            default_value = " = #{default_value}"
          elsif type == "Bool"
            default_value = " = #{default_value}"
          else
            default_value = " = \"#{default_value}\""
          end
        end

        # if we don't have a default value, but the param is options, just set a default value to nil
        if optional
          default_value ||= " = nil"
        end

        default_value ||= "" # erase the default value from the swift param string since it's nil
        # that's because it means we don't have a default value nor optional value so we must get one

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

  class SwiftFastlaneAPIGenerator
    attr_accessor :categories

    def initialize
      require 'fastlane'
      require 'fastlane/documentation/actions_list'
      Fastlane.load_actions
    end

    def generate_swift(target_path: "swift/Fastlane.swift")
      file_content = []

      ActionsList.all_actions do |action|
        swift_function = process_action(action: action)
        unless swift_function
          next
        end

        file_content << swift_function.swift_code
      end
      file_content << "\n" # newline because <reasons>
      file_content = file_content.join("\n")

      File.write(target_path, file_content)
      UI.success(target_path)
      # File.write(, swift_code)
    end

    def process_action(action: nil)
      unless action.available_options
        return nil
      end
      options = action.available_options

      action_name = action.action_name
      keys = []
      key_descriptions = []
      key_default_values = []
      key_optionality_values = []

      if options.kind_of? Array
        options.each do |current|
          next unless current.kind_of? FastlaneCore::ConfigItem
          keys << current.key.to_s
          key_descriptions << current.description
          key_default_values << current.default_value
          key_optionality_values << current.optional

          # elsif current.kind_of? Array
          #   # Legacy actions that don't use the new config manager
          #   UI.user_error!("Invalid number of elements in this row: #{current}. Must be 2 or 3") unless [2, 3].include? current.count
          #   rows << current
          #   rows.last[0] = rows.last.first.yellow # color it yellow :)
          #   rows.last << nil while rows.last.count < 4 # to have a nice border in the table
          # end
        end
      end
      action_return_type = action.return_type

      return SwiftFunction.new(
        action_name: action_name,
        keys: keys,
        key_descriptions: key_descriptions,
        key_default_values: key_default_values,
        key_optionality_values: key_optionality_values,
        return_type: action_return_type
      )
    end
  end
end
