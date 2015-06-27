module FastlaneCore
  class ConfigItem
    attr_accessor :key, :env_name, :description, :short_option, :default_value, :verify_block, :is_string, :optional

    # Creates a new option
    # @param key (Symbol) the key which is used as command paramters or key in the fastlane tools
    # @param env_name (String) the name of the environment variable, which is only used if no other values were found
    # @param description (String) A description shown to the user
    # @param short_option (String) A string of length 1 which is used for the command parameters (e.g. -f)
    # @param default_value the value which is used if there was no given values and no environment values
    # @param verify_block an optional block which is called when a new value is set. 
    #   Check value is valid. This could be type checks or if a folder/file exists
    #   You have to raise a specific exception if something goes wrong. Append .red after the string
    # @param is_string (String) is that parameter a string? Defaults to true. If it's true, the type string will be verified.
    # @param optional (Boolean) is false by default. If set to true, also string values will not be asked to the user
    def initialize(key: nil, env_name: nil, description: nil, short_option: nil, default_value: nil, verify_block: nil, is_string: true, optional: false)
      raise "key must be a symbol" unless key.kind_of?Symbol
      raise "env_name must be a String" unless (env_name || '').kind_of?String
      if short_option
        raise "short_option must be a String of length 1" unless (short_option.kind_of?String and short_option.gsub('-', '').length == 1)
      end
      if description
        raise "Do not let descriptions end with a '.', since it's used for user inputs as well".red if (description[-1] == '.')
      end

      @key = key
      @env_name = env_name
      @description = description
      @short_option = short_option
      @default_value = default_value
      @verify_block = verify_block
      @is_string = is_string
      @optional = optional
    end


    # This will raise an exception if the value is not valid
    def verify!(value)
      raise "Invalid value '#{value}' for option '#{self}'".red unless is_valid?value
      true
    end

    # Make sure, the value is valid (based on the verify block)
    # Returns false if that's not the case
    def is_valid?(value)
      # we also allow nil values, which do not have to be verified. 
      if value
        if @is_string
          raise "'#{self.key}' value must be a String! Found #{value.class} instead.".red unless value.kind_of?String
        end
        
        if @verify_block
          begin
            @verify_block.call(value)
          rescue Exception => ex
            Helper.log.fatal "Error setting value '#{value}' for option '#{@key}'".red
            raise ex
          end
        end
      end

      true
    end

    def to_s
      [@key, @description].join(": ")
    end
  end
end