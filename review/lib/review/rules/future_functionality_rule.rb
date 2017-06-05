require 'review/rule'
require 'review/rules/abstract_text_match_rule'

module Review
  class FutureFunctionalityRule < AbstractTextMatchRule
    def self.key
      :future_functionality
    end

    def self.env_name
      "RULE_FUTURE_FUNCTIONALITY"
    end

    def self.description
      "Don't mention features or content that is not currently available in your app"
    end

    def self.lowercased_words_to_look_for
      [
        "coming soon",
        "coming shortly",
        "in the next release",
        "arriving soon",
        "arriving shortly",
        "here soon",
        "here shortly"
      ].map(&:downcase)
    end
  end
end
