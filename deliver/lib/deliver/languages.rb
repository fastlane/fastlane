require 'fastlane_core/languages'

module Deliver
  module Languages
    ALL_LANGUAGES = FastlaneCore::Languages::ALL_LANGUAGES

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
