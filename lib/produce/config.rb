module Produce
  class Config
    ASK_MESSAGES = {
      bundle_identifier: "App Identifier (Bundle ID, e.g. com.krausefx.app): ",
      app_name: "App Name: ",
      version: "Initial version number (e.g. '1.0'): ",
      sku: "SKU Number (e.g. '1234'): ",
      primary_language: "Primary Language (e.g. 'English', 'German'): "
    }

    attr_reader :config

    def self.shared_config
      @@shared ||= self.new(options)
    end

    def self.shared_config= config
      @@shared = config
    end

    def env_options
      hash = {
        bundle_identifier: ENV['PRODUCE_APP_IDENTIFIER'],
        app_name: ENV['PRODUCE_APP_NAME'],
        version: ENV['PRODUCE_VERSION'],
        sku: ENV['PRODUCE_SKU'],
        skip_itc: skip_itc?(ENV['PRODUCE_SKIP_ITC'])
      }
      hash[:primary_language] = 
        ENV['PRODUCE_LANGUAGE'] if is_valid_language?(ENV['PRODUCE_LANGUAGE'])
      hash[:bundle_identifier] ||= CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
      hash.delete_if { |key, value| value.nil? }
      hash
    end

    def initialize(options = {})
      @config = env_options.merge(options)
    end

    def self.val(key)
      raise "Please only pass symbols, no Strings to this method".red unless key.kind_of? Symbol

      unless self.shared_config.config.has_key? key
        validation = case key
        when :primary_language
          lambda { |val| is_valid_language?(val) }
        else
          lambda { |val| !val.strip.empty? }
        end

        self.shared_config.config[key] = ask(ASK_MESSAGES[key]) { |q| q.validate = validation }
      end

      return self.shared_config.config[key]
    end

    def is_valid_language? language
      language = language.split.map(&:capitalize).join(' ')
      if AvailableDefaultLanguages.all_langauges.include?(input)
        true
      else
        Helper.log.error "Could not find langauge #{language} - available languages: #{AvailableDefaultLanguages.all_langauges}"
        false
      else
    end

    def skip_itc? value
      %w( true t 1 yes y ).include? value.to_s.downcase
    end
  end
end