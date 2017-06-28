module Spaceship
  module Tunes
    # Represents one attribute (e.g. name) of an app in multiple languages
    class LanguageItem
      attr_accessor :identifier # title or description
      attr_accessor :original_array # reference to original array

      def initialize(identifier, ref)
        raise "ref is nil" if ref.nil?

        self.identifier = identifier.to_s
        self.original_array = ref
      end

      def [](key)
        get_value(key: key)
      end

      def []=(key, value)
        get_lang(key)[identifier]['value'] = value
      end

      def get_value(key: nil)
        get_lang(key)[identifier]['value']
      end

      def get_lang(lang)
        result = self.original_array.find do |current|
          lang = lang.to_s
          current['language'] == lang or current['localeCode'] == lang # Apple being consistent
        end
        return result if result

        raise "Language '#{lang}' is not activated / available for this app version."
      end

      # @return (Array) An array containing all languages that are already available
      def keys
        return self.original_array.map { |current| current['language'] ||= current['localeCode'] } # Apple being consistent
      end

      # @return (Array) An array containing all languages that are already available
      #   alias for keys
      def languages
        keys
      end

      def inspect
        result = ""
        self.original_array.collect do |current|
          result += "#{current['language'] ||= current['localeCode']}: #{current.fetch(identifier, {}).fetch('value')}\n"
        end
        result
      end

      def to_s
        inspect
      end
    end
  end
end
