require 'review/rule'
require 'review/rules/abstract_text_match_rule'

module Review
  class PlaceholderWordsRule < AbstractTextMatchRule
    def self.key
      :placeholder_text
    end

    def self.env_name
      "RULE_PLACEHOLDER_TEXT_THINGS"
    end

    def self.description
      "Don't use Placeholder text, or anything indicating this isn't an App Store ready build"
    end

    def self.lowercased_words_to_look_for
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
