require 'fastlane_core/configuration/config_item'
require 'fastlane_core/configuration/commander_generator'
require 'fastlane_core/configuration/configuration_file'

module FastlaneCore
  class Configuration

    attr_accessor :available_options

    attr_accessor :values

    # @return [Array] An array of symbols which are all available keys
    attr_reader :all_keys

    # @return [String] The name of the configuration file (not the path). Optional!
    attr_accessor :config_file_name

    def self.create(available_options, values)
      Configuration.new(available_options, values)
    end

    #####################################################
    # @!group Setting up the configuration
    #####################################################
    
    def initialize(available_options, values)
      self.available_options = available_options || []
      self.values = values || {}

      verify_input_types      
      verify_value_exists
      verify_no_duplicates
      verify_default_value_matches_verify_block
    end

    def verify_input_types
      raise "available_options parameter must be an array of ConfigItems but is #{@available_options.class}".red unless @available_options.kind_of?Array
      @available_options.each do |item|
        raise "available_options parameter must be an array of ConfigItems. Found #{item.class}.".red unless item.kind_of?ConfigItem
      end
      raise "values parameter must be a hash".red unless @values.kind_of?Hash
    end

    def verify_value_exists
      # Make sure the given value keys exist
      @values.each do |key, value|
        option = option_for_key(key)
        if option
          option.verify!(value) # Call the verify block for it too
        else
          raise "Could not find option '#{key}' in the list of available options: #{@available_options.collect { |a| a.key }.join(', ')}".red
        end
      end
    end

    def verify_no_duplicates
      # Make sure a key was not used multiple times
      @available_options.each do |current|
        count = @available_options.select { |option| option.key == current.key }.count
        raise "Multiple entries for configuration key '#{current.key}' found!".red if count > 1

        unless current.short_option.to_s.empty?
          count = @available_options.select { |option| option.short_option == current.short_option }.count
          raise "Multiple entries for short_option '#{current.short_option}' found!".red if count > 1
        end
      end
    end

    # Verifies the default value is also valid
    def verify_default_value_matches_verify_block
      @available_options.each do |item|
        if item.verify_block and item.default_value
          begin
            item.verify_block.call(item.default_value)
          rescue => ex
            Helper.log.fatal ex
            raise "Invalid default value for #{item.key}, doesn't match verify_block".red
          end
        end
      end
    end

    # This method takes care of parsing and using the configuration file as values
    # Call this once you know where the config file might be located
    # Take a look at how `gym` uses this method
    # 
    # @param config_file_name [String] The name of the configuration file to use (optional)
    # @param block_for_missing [Block] A ruby block that is called when there is an unkonwn method
    #   in the configuration file
    def load_configuration_file(config_file_name = nil, block_for_missing = nil)
      return unless config_file_name

      self.config_file_name = config_file_name

      paths = Dir["./fastlane/#{self.config_file_name}"] + Dir["./#{self.config_file_name}"]
      paths = paths + Dir["./spec/fixtures/#{self.config_file_name}"] if Helper.is_test?
      return if paths.count == 0

      path = paths.first
      ConfigurationFile.new(self, path, block_for_missing)
    end

    #####################################################
    # @!group Actually using the class
    #####################################################

    # Returns the value for a certain key. fastlane_core tries to fetch the value from different sources
    def fetch(key)
      raise "Key '#{key}' must be a symbol. Example :app_id.".red unless key.kind_of?Symbol

      option = option_for_key(key)
      raise "Could not find option for key :#{key}. Available keys: #{@available_options.collect { |a| a.key }.join(', ')}".red unless option

      value = @values[key]
      
      # `if value == nil` instead of ||= because false is also a valid value
      if value == nil and option.env_name and ENV[option.env_name]
        value = ENV[option.env_name].dup
        option.verify!(value) if value
      end

      value = option.default_value if value == nil
      value = nil if (value == nil and not option.is_string) # by default boolean flags are false

      return value unless value.nil? # we already have a value
      return value if option.optional # as this value is not required, just return what we have
      

      if Helper.is_test? or Helper.is_ci?
        # Since we don't want to be asked on tests, we'll just call the verify block with no value
        # to raise the exception that is shown when the user passes an invalid value
        set(key, '')
        # If this didn't raise an exception, just raise a default one
        raise "No value found for '#{key}'"
      end

      while value == nil
        Helper.log.info "To not be asked about this value, you can specify it using '#{option.key}'".yellow
        value = ask("#{option.description}: ")
        # Also store this value to use it from now on
        begin
          set(key, value)
        rescue Exception => ex
          puts ex
          value = nil
        end
      end

      value
    end

    # Overwrites or sets a new value for a given key
    # @param key [Symbol] Must be a symbol
    def set(key, value)
      raise "Key '#{key}' must be a symbol. Example :#{key}.".red unless key.kind_of?Symbol
      option = option_for_key(key)
      
      unless option
        raise "Could not find option '#{key}' in the list of available options: #{@available_options.collect { |a| a.key }.join(', ')}".red
      end

      option.verify!(value)

      @values[key] = value
      true
    end

    def values
      # As the user accesses all values, we need to iterate through them to receive all the values
      @available_options.each do |option|
        @values[option.key] = fetch(option.key) unless @values[option.key]
      end
      @values
    end

    def all_keys
      @available_options.collect { |o| o.key }
    end

    # Returns the config_item object for a given key
    def option_for_key(key)
      @available_options.find { |o| o.key == key }
    end

    # Aliases `[key]` to `fetch(key)` because Ruby can do it.
    alias_method :[], :fetch
    alias_method :[]=, :set
  end
end