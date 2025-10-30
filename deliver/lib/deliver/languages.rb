module Deliver
  module Languages
    # 2020-08-24 - Available locales are not available as an endpoint in App Store Connect
    # Update with Spaceship::Tunes.client.available_languages.sort (as long as endpoint is available)
    ALL_LANGUAGES = %w[ar-SA ca cs da de-DE el en-AU en-CA en-GB en-US es-ES es-MX fi fr-CA fr-FR he hi hr hu id it ja ko ms nl-NL no pl pt-BR pt-PT ro ru sk sv th tr uk vi zh-Hans zh-Hant]

    # Detects all enabled languages from various sources
    # @param options [Hash] The options hash containing language settings
    # @param localized_values_keys [Array<Symbol>] Keys to check for localized values in options
    # @param metadata_path [String, nil] Path to metadata folder to check for language folders
    # @param ignore_validation [Boolean] Whether to ignore language directory validation
    # @return [Array<String>] List of unique enabled language codes
    def self.detect_languages(options:, localized_values_keys: [], metadata_path: nil, ignore_validation: false)
      require_relative 'loader'

      enabled_languages = options[:languages] || []

      # Get all languages used in existing localized settings
      localized_values_keys.each do |key|
        current = options[key]
        next unless current && current.kind_of?(Hash)
        current.each do |language, value|
          enabled_languages << language unless enabled_languages.include?(language)
        end
      end

      # Check folder list if metadata_path is provided (an empty folder signifies a language is required)
      if metadata_path
        Loader.language_folders(metadata_path, ignore_validation).each do |lang_folder|
          enabled_languages << lang_folder.basename unless enabled_languages.include?(lang_folder.basename)
        end
      end

      # Mapping to strings because :default symbol can be passed in
      enabled_languages
        .map(&:to_s)
        .uniq
    end
  end
end
