require_relative 'abstract_text_match_rule'

module Precheck
  class PlaceholderWordsRule < AbstractTextMatchRule
    def self.key
      :placeholder_text
    end

    def self.env_name
      "RULE_PLACEHOLDER_TEXT_THINGS"
    end

    def self.friendly_name
      "No placeholder text"
    end

    def self.description
      "using placeholder text (e.g.:\"lorem ipsum\", \"text here\", etc...)"
    end

    def lowercased_words_to_look_for
      [
        "hipster ipsum",
        "bacon ipsum",
        "lorem ipsum",
        "placeholder",
        "text here"
      ].map(&:downcase)
    end
  end
end
