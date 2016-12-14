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
      UI.user_error!("values parameter must be a hash") unless values.kind_of?(Hash)
      v = values.dup
      v.each do |key, val|
        v[key] = val.dup if val.kind_of?(String) # this is necessary when fetching a value from an environment variable
      end

      if v.kind_of?(Hash) && available_options.kind_of?(Array) # we only want to deal with the new configuration system
        # Now see if --verbose would be a valid input
        # If not, it might be because it's an action and not a tool
        unless available_options.find { |a| a.kind_of?(ConfigItem) && a.key == :verbose }
          v.delete(:verbose) # as this is being processed by commander
        end
      end
      Configuration.new(available_options, v)
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
      verify_conflicts
      verify_default_value_matches_verify_block
    end

    def verify_input_types
      UI.user_error!("available_options parameter must be an array of ConfigItems but is #{@available_options.class}") unless @available_options.kind_of? Array
      @available_options.each do |item|
        UI.user_error!("available_options parameter must be an array of ConfigItems. Found #{item.class}.") unless item.kind_of? ConfigItem
      end
      UI.user_error!("values parameter must be a hash") unless @values.kind_of?(Hash)
    end

    def verify_value_exists
      # Make sure the given value keys exist
      @values.each do |key, value|
        next if key == :trace # special treatment
        option = option_for_key(key)
        if option
          @values[key] = option.auto_convert_value(value)
          UI.deprecated("Using deprecated option: '--#{key}' (#{option.deprecated})") if option.deprecated
          option.verify!(@values[key]) # Call the verify block for it too
        else
          UI.user_error!("Could not find option '#{key}' in the list of available options: #{@available_options.collect(&:key).join(', ')}")
        end
      end
    end

    def verify_no_duplicates
      # Make sure a key was not used multiple times
      @available_options.each do |current|
        count = @available_options.count { |option| option.key == current.key }
        UI.user_error!("Multiple entries for configuration key '#{current.key}' found!") if count > 1

        unless current.short_option.to_s.empty?
          count = @available_options.count { |option| option.short_option == current.short_option }
          UI.user_error!("Multiple entries for short_option '#{current.short_option}' found!") if count > 1
        end
      end
    end

    def verify_conflicts
      option_keys = @values.keys

      option_keys.each do |current|
        index = @available_options.find_index { |item| item.key == current }
        current = @available_options[index]

        # ignore conflicts because option value is nil
        next if @values[current.key].nil?

        next if current.conflicting_options.nil?

        conflicts = current.conflicting_options & option_keys
        next if conflicts.nil?

        conflicts.each do |conflicting_option_key|
          index = @available_options.find_index { |item| item.key == conflicting_option_key }
          conflicting_option = @available_options[index]

          # ignore conflicts because because value of conflict option is nil
          next if @values[conflicting_option.key].nil?

          if current.conflict_block
            begin
              current.conflict_block.call(conflicting_option)
            rescue => ex
              UI.error("Error resolving conflict between options: '#{current.key}' and '#{conflicting_option.key}'")
              raise ex
            end
          else
            UI.user_error!("Unresolved conflict between options: '#{current.key}' and '#{conflicting_option.key}'")
          end
        end
      end
    end

    # Verifies the default value is also valid
    def verify_default_value_matches_verify_block
      @available_options.each do |item|
        next unless item.verify_block && item.default_value

        begin
          unless @values[item.key] # this is important to not verify if there already is a value there
            item.verify_block.call(item.default_value)
          end
        rescue => ex
          UI.error(ex)
          UI.user_error!("Invalid default value for #{item.key}, doesn't match verify_block")
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

      paths = []
      paths += Dir["./fastlane/#{self.config_file_name}"]
      paths += Dir["./.fastlane/#{self.config_file_name}"]
      paths += Dir["./#{self.config_file_name}"]
      paths += Dir["./fastlane_core/spec/fixtures/#{self.config_file_name}"] if Helper.is_test?
      return if paths.count == 0

      path = paths.first
      configuration_file = ConfigurationFile.new(self, path, block_for_missing)
      verify_conflicts # important, since user can set conflicting options in configuration file
      configuration_file
    end

    #####################################################
    # @!group Actually using the class
    #####################################################

    # Returns the value for a certain key. fastlane_core tries to fetch the value from different sources
    # if 'ask' is true and the value is not present, the user will be prompted to provide a value
    def fetch(key, ask: true)
      UI.user_error!("Key '#{key}' must be a symbol. Example :app_id.") unless key.kind_of?(Symbol)

      option = option_for_key(key)
      UI.user_error!("Could not find option for key :#{key}. Available keys: #{@available_options.collect(&:key).join(', ')}") unless option

      value = @values[key]

      value = option.auto_convert_value(value)

      # `if value == nil` instead of ||= because false is also a valid value
      if value.nil? and option.env_name and ENV[option.env_name]

        # We want to inform the user that we took the value
        # from an environment variable
        # however we don't print the actual value, as it may contain sensitive information
        # The user can easily find the actual value by print out the environment
        UI.verbose("Taking value for '#{key}' from environment variable '#{option.env_name}'")

        value = option.auto_convert_value(ENV[option.env_name].dup)
        option.verify!(value) if value
      end

      value = option.default_value if value.nil?
      value = nil if value.nil? and !option.string? # by default boolean flags are false

      return value unless value.nil? # we already have a value
      return value if option.optional # as this value is not required, just return what we have

      return value unless ask

      # fallback to asking
      if Helper.is_test? or !UI.interactive?
        # Since we don't want to be asked on tests, we'll just call the verify block with no value
        # to raise the exception that is shown when the user passes an invalid value
        set(key, '')
        # If this didn't raise an exception, just raise a default one
        UI.user_error!("No value found for '#{key}'")
      end

      while value.nil?
        UI.important("To not be asked about this value, you can specify it using '#{option.key}'")
        value = option.sensitive ? UI.password("#{option.description}: ") : UI.input("#{option.description}: ")
        # Also store this value to use it from now on
        begin
          set(key, value)
        rescue => ex
          puts ex
          value = nil
        end
      end

      value
    end

    # Overwrites or sets a new value for a given key
    # @param key [Symbol] Must be a symbol
    def set(key, value)
      UI.user_error!("Key '#{key}' must be a symbol. Example :#{key}.") unless key.kind_of? Symbol
      option = option_for_key(key)

      unless option
        UI.user_error!("Could not find option '#{key}' in the list of available options: #{@available_options.collect(&:key).join(', ')}")
      end

      option.verify!(value)

      @values[key] = value
      true
    end

    # see fetch
    def values(ask: true)
      # As the user accesses all values, we need to iterate through them to receive all the values
      @available_options.each do |option|
        @values[option.key] = fetch(option.key, ask: ask) unless @values[option.key]
      end
      @values
    end

    # Direct access to the values, without iterating through all items
    def _values
      @values
    end

    def all_keys
      @available_options.collect(&:key)
    end

    # Returns the config_item object for a given key
    def option_for_key(key)
      @available_options.find { |o| o.key == key }
    end

    # Aliases `[key]` to `fetch(key)` because Ruby can do it.
    alias [] fetch
    alias []= set
  end
end
