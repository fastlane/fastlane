module Spaceship
  module Tunes
    # Represents one attribute (e.g. name) of an app in multiple languages
    class LanguageItem
      attr_accessor :identifier # title or description
      attr_accessor :original_array # reference to original array

      def initialize(identifier, ref)
        self.identifier = identifier.to_s
        self.original_array = ref
      end

      def [](key)
        get_lang(key)[identifier]['value']
      end

      def []=(key, value)
        get_lang(key)[identifier]['value'] = value
      end

      def get_lang(lang)
        result = self.original_array.find do |current|
          current['language'] == lang
        end
        return result if result

        raise "Language '#{lang}' is not activated for this app version. Use the `create_languages!` method."
      end
      end
    end
  end
end