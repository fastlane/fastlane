module FastlaneCore
  class ConfigItem
    attr_accessor :key, :env_name, :description, :short_option, :default_value, :verify_block, :optional

    # Creates a new option
    # @param key (Symbol) the key which is used as command paramters or key in the fastlane tools
    # @param env_name (String) the name of the environment variable, which is only used if no other values were found
    # @param description (String) A description shown to the user
    # @param short_option (String) A string of length 1 which is used for the command parameters (e.g. -f)
    # @param default_value the value which is used if there was no given values and no environment values
    # @param verify_block an optional block which is called when a new value is set.
    #   Check value is valid. This could be type checks or if a folder/file exists
    #   You have to raise a specific exception if something goes wrong. Append .red after the string
    # @param is_string *DEPRECATED: Use `type` instead* (Boolean) is that parameter a string? Defaults to true. If it's true, the type string will be verified.
    # @param type (Class) the data type of this config item. Takes precedence over `is_string`
    # @param optional (Boolean) is false by default. If set to true, also string values will not be asked to the user
    def initialize(key: nil, env_name: nil, description: nil, short_option: nil, default_value: nil, verify_block: nil, is_string: true, type: nil, optional: false)
      raise "key must be a symbol" unless key.kind_of? Symbol
      raise "env_name must be a String" unless (env_name || '').kind_of? String

      if short_option
        raise "short_option must be a String of length 1" unless short_option.kind_of? String and short_option.delete('-').length == 1
      end
      if description
        raise "Do not let descriptions end with a '.', since it's used for user inputs as well".red if description[-1] == '.'
      end

      if type.to_s.length > 0 and short_option.to_s.length == 0
        raise "Type '#{type}' for key '#{key}' requires a short option"
      end

      @key = key
      @env_name = env_name
      @description = description
      @short_option = short_option
      @default_value = default_value
      @verify_block = verify_block
      @is_string = is_string
      @data_type = type
      @optional = optional
    end

    # This will raise an exception if the value is not valid
    def verify!(value)
      raise "Invalid value '#{value}' for option '#{self}'".red unless valid? value
      true
    end

    # Make sure, the value is valid (based on the verify block)
    # Returns false if that's not the case
    def valid?(value)
      # we also allow nil values, which do not have to be verified.
      if value
        # Verify that value is the type that we're expecting, if we are expecting a type
        if data_type && !value.kind_of?(data_type)
          raise "'#{self.key}' value must be a #{data_type}! Found #{value.class} instead.".red
        end

        if @verify_block
          begin
            @verify_block.call(value)
          rescue => ex
            Helper.log.fatal "Error setting value '#{value}' for option '#{@key}'".red
            raise ex
          end
        end
      end

      true
    end

    # Returns an updated value type (if necessary)
    def auto_convert_value(value)
      # Weird because of https://stackoverflow.com/questions/9537895/using-a-class-object-in-case-statement

      case
      when data_type == Array
        return value.split(',') if value.kind_of?(String)
      when data_type == Integer
        return value.to_i
      when data_type == Float
        return value.to_f
      else
        # Special treatment if the user specififed true, false or YES, NO
        # There is no boolean typoe, so we just do it here
        if %w(YES yes true).include?(value)
          return true
        elsif %w(NO no false).include?(value)
          return false
        end
      end

      return value # fallback to not doing anything
    end

    # Determines the defined data type of this ConfigItem
    def data_type
      if @data_type
        @data_type
      else
        (@is_string ? String : nil)
      end
    end

    # Replaces the attr_accessor, but maintains the same interface
    def string?
      data_type == String
    end

    def to_s
      [@key, @description].join(": ")
    end
  end
end
