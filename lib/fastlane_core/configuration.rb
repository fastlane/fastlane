require 'fastlane_core/configuration/config_item'

module FastlaneCore
  class Configuration
    def self.create(available_options, values)
      Configuration.new(available_options, values)
    end

    def initialize(available_options, values)
      @available_options = available_options
      @values = values

      raise "available_options parameter must be an array of ConfigItems".red unless available_options.kind_of?Array
      available_options.each do |item|
        raise "available_options parameter must be an array of ConfigItems".red unless item.kind_of?ConfigItem
      end

      raise "values parameter must be a hash".red unless values.kind_of?Hash

      # Make sure they exist
      values.each do |key, value|
        option = option_for_key(key)
        if option
          # Call the verify block for it too
          option.verify!(value)
        else
          raise "Could not find available option '#{key}' in the list of available options (#{@available_options.collect { |a| a.key }})".red
        end
      end
    end

    # Returns the value for a certain key. fastlane_core tries to fetch the value from different sources
    def fetch(key)
      raise "Key '#{key}' must be a symbol. Example :app_id.".red unless key.kind_of?Symbol

      value ||= @values[key]
      # TODO: configuration files
      value ||= ENV[key.to_s]
      value ||= option_for_key(key).default_value
      # TODO: add more sources here

      value
    end

    # Overwrites or sets a new value for a given key
    def set(key, value)
      raise "Key '#{key}' must be a symbol. Example :app_id.".red unless key.kind_of?Symbol
      option = option_for_key(key)
      
      unless option
        raise "Could not find available option '#{key}' in the list of !available options (#{@available_options.collect { |a| a.key }})".red
      end

      option.verify!(value)

      @values[key] = value
      true
    end

    # Returns the config_item object for a given key
    def option_for_key(key)
      @available_options.find { |o| o.key == key }
    end

    # Aliases `[key]` to `fetch(key)` because Ruby can do it.
    alias_method :[], :fetch
  end
end