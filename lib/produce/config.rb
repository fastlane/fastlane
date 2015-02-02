module Produce
  class Config
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
      hash
    end

    def initialize(options = {})
      @config = env_options.merge(options)

      @config[:bundle_identifier] ||= ask("App Identifier (Bundle ID, e.g. com.krausefx.app): ")
      @config[:app_name] ||= ask("App Name: ")
      
      if @config[:skip_itc].to_s.length == 0
        while @config[:primary_language].to_s.length == 0
          input = ask("Primary Language (e.g. 'English', 'German'): ")
          input = input.split.map(&:capitalize).join(' ')
          if not AvailableDefaultLanguages.all_langauges.include?(input)
            Helper.log.error "Could not find langauge #{input} - available languages: #{AvailableDefaultLanguages.all_langauges}"
          else
            @config[:primary_language] = input
          end
        end

        @config[:version] ||= ask("Initial version number (e.g. '1.0'): ")
        @config[:sku] ||= ask("SKU Number (e.g. '1234'): ")
      end
    end

    def self.val(key)
      raise "Please only pass symbols, no Strings to this method".red unless key.kind_of? Symbol
      self.shared_config.config[key]
    end

    def is_valid_language? language
      AvailableDefaultLanguages.all_langauges.include? language
    end

    def skip_itc? value
      %w( true t 1 yes y ).include? value.to_s.downcase
    end
  end
end