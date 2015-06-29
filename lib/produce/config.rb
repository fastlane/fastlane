module Produce
  class Config
    ASK_MESSAGES = {
      bundle_identifier: "App Identifier (Bundle ID, e.g. com.krausefx.app): ",
      bundle_identifier_suffix: "App Identifier Suffix (Ignored if App Identifier does not ends with .*): ",
      app_name: "App Name: ",
      version: "Initial version number (e.g. '1.0'): ",
      sku: "SKU Number (e.g. '1234'): ",
      primary_language: "Primary Language (e.g. 'English', 'German'): "
    }

    # Left to prevent fastlane from crashing. Should be removed upon version bump.
    def self.shared_config
    end

    # Creates new Config instance using ENV variables.
    # @param options (Hash) (optional) config options hash. If duplicates keys
    # specified by ENV variable, `options` has value will be used.
    # @return (Config) created Config instance
    def initialize(options = {})
      @config = env_options.merge(options)
    end

    # Retrieves the value for given `key`. If not found, will promt user with
    # `ASK_MESSAGES[key]` till gets valid response. Thus, always returns value.
    # Raises exception if given `key` is not Symbol or unknown.
    def val(key)
      raise "Please only pass symbols, no Strings to this method".red unless key.kind_of? Symbol
      
      # bundle_identifier_suffix can be set to empty string, if bundle_identifier is not a wildcard id
      # (does not end with '*'). bundle_identifier_suffix is ignored on non wildcard bundle_identifiers
      if key == :bundle_identifier_suffix
        unless @config[:bundle_identifier].end_with?("*")
          @config[key] = '' # set empty string, if no wildcard bundle_indentifiier
        end
      end

      return nil if key == :company_name

      unless @config.has_key?key
        @config[key] = ask(ASK_MESSAGES[key]) do |q|
          case key
          when :primary_language
            q.validate = lambda { |val| is_valid_language?(val) }
            q.responses[:not_valid] = "Please enter one of available languages: #{AvailableDefaultLanguages.all_languages}"
          else
            q.validate = lambda { |val| !val.empty? }
            q.responses[:not_valid] = "#{key.to_s.gsub('_', ' ').capitalize} can't be blank"
          end
        end
      end

      return @config[key]
    end

    # Aliases `[key]` to `val(key)` because Ruby can do it.
    alias_method :[], :val

    # Returns true if option for the given key is present.
    def has_key?(key)
      @config.has_key? key
    end

    private

    def env_options
      hash = {
        bundle_identifier: ENV['PRODUCE_APP_IDENTIFIER'],
        bundle_identifier_suffix: ENV['PRODUCE_APP_IDENTIFIER_SUFFIX'],
        app_name: ENV['PRODUCE_APP_NAME'],
        version: ENV['PRODUCE_VERSION'],
        sku: ENV['PRODUCE_SKU'] || Time.now.to_i.to_s,
        skip_itc: is_truthy?(ENV['PRODUCE_SKIP_ITC']),
        skip_devcenter: is_truthy?(ENV['PRODUCE_SKIP_DEVCENTER']),
        team_id: ENV['PRODUCE_TEAM_ID'],
        company_name: ENV['PRODUCE_COMPANY_NAME']
      }
      
      if ENV['PRODUCE_LANGUAGE']
        language = valid_language(ENV['PRODUCE_LANGUAGE'])

        if language.nil?
          unknown_language = ENV['PRODUCE_LANGUAGE']
          Helper.log.error "PRODUCE_LANGUAGE is set to #{unknown_language} but it's not one of available languages. You'll be asked to set language again if needed."          
        else
          hash[:primary_language] = language
        end
      end

      hash[:bundle_identifier] ||= CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
      hash.delete_if { |key, value| value.nil? }
      hash
    end


    def is_valid_language?(language)
      AvailableDefaultLanguages.all_languages.include? language
    end

    def valid_language(language)
      AvailableDefaultLanguages.all_languages.each do |l| 

        if l.casecmp(language) == 0
          return l
        end

      end

      return nil
    end

    # TODO: this could be moved inside fastlane_core
    def is_truthy?(value)
      %w( true t 1 yes y ).include? value.to_s.downcase
    end

  end
end
