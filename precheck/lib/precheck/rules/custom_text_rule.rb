require_relative 'abstract_text_match_rule'

module Precheck
  class CustomTextRule < AbstractTextMatchRule
    attr_accessor :data

    def self.key
      :custom_text
    end

    def self.env_name
      "RULE_CUSTOM_TEXT"
    end

    def self.friendly_name
      "No user-specified words are included"
    end

    def self.description
      "mentioning any of the user-specified words passed to #{self.key}(data: [words])"
    end

    def needs_customization?
      return true
    end

    def lowercased_words_to_look_for
      return @data
    end

    def customize_with_data(data: nil)
      @data = data.map { |word| word.strip.downcase }
    end
  end
end
