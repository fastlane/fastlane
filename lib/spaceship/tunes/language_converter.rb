module Spaceship
  module Tunes
    class LanguageConverter
      class << self
        # Converts the iTC format (English_CA, Brazilian Portuguese) to language short codes: (en-US, de-DE)
        def from_itc_to_standard(from)
          result = mapping.find { |a| a['name'] == from }
          (result || {}).fetch('locale', nil)
        end

        # Converts the language short codes: (en-US, de-DE) to the iTC format (English_CA, Brazilian Portuguese)
        def from_standard_to_itc(from)
          result = mapping.find { |a| a['locale'] == from || (a['alternatives'] || []).include?(from) }
          (result || {}).fetch('name', nil)
        end

        # Converts the langauge "UK English" (user facing) to "English_UK" (value)
        def from_itc_readable_to_itc(from)
          readable_mapping.each do |key, value|
            return key if value == from
          end
          nil
        end

        # Converts the langauge "English_UK" (value) to "UK English" (user facing)
        def from_itc_to_itc_readable(from)
          readable_mapping[from]
        end

        private

        # Path to the gem to fetch resoures
        def spaceship_gem_path
          if Gem::Specification.find_all_by_name('spaceship').any?
            return Gem::Specification.find_by_name('spaceship').gem_dir
          else
            return './'
          end
        end

        # Get the mapping JSON parsed
        def mapping
          @languages ||= JSON.parse(File.read(File.join(spaceship_gem_path, "lib", "assets", "languageMapping.json")))
        end

        def readable_mapping
          @readable ||= JSON.parse(File.read(File.join(spaceship_gem_path, "lib", "assets", "languageMappingReadable.json")))
        end
      end
    end
  end
end

class String
  def to_language_code
    Spaceship::Tunes::LanguageConverter.from_itc_to_standard(self)
  end

  def to_full_language
    Spaceship::Tunes::LanguageConverter.from_standard_to_itc(self)
  end
end
