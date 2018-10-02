require_relative '../module'

module Spaceship
  module Tunes
    class LanguageConverter
      class << self
        # Converts the iTC format (English_CA, Brazilian Portuguese) to language short codes: (en-US, de-DE)
        def from_itc_to_standard(from)
          result = mapping.find { |a| a['name'] == from }
          (result || {}).fetch('locale', nil)
        end

        # Converts the Language "UK English" to itc locale en-GB
        def from_standard_to_itc_locale(from)
          result = mapping.find { |a| a['name'] == from } || {}
          return result['itc_locale'] || result['locale']
        end

        # Converts the language short codes: (en-US, de-DE) to the iTC format (English_CA, Brazilian Portuguese)
        def from_standard_to_itc(from)
          result = mapping.find { |a| a['locale'] == from || (a['alternatives'] || []).include?(from) }
          (result || {}).fetch('name', nil)
        end

        # Converts the language "UK English" (user facing) to "English_UK" (value)
        def from_itc_readable_to_itc(from)
          readable_mapping.each do |key, value|
            return key if value == from
          end
          nil
        end

        # Converts the language "English_UK" (value) to "UK English" (user facing)
        def from_itc_to_itc_readable(from)
          readable_mapping[from]
        end

        private

        # Get the mapping JSON parsed
        def mapping
          @languages ||= JSON.parse(File.read(File.join(Spaceship::ROOT, "lib", "assets", "languageMapping.json")))
        end

        def readable_mapping
          @readable ||= JSON.parse(File.read(File.join(Spaceship::ROOT, "lib", "assets", "languageMappingReadable.json")))
        end
      end
    end
  end
end

class String
  def to_language_code
    Spaceship::Tunes::LanguageConverter.from_itc_to_standard(self)
  end

  def to_itc_locale
    Spaceship::Tunes::LanguageConverter.from_standard_to_itc_locale(self)
  end

  def to_full_language
    Spaceship::Tunes::LanguageConverter.from_standard_to_itc(self)
  end
end
