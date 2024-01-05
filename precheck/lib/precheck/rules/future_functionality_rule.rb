require_relative 'abstract_text_match_rule'

module Precheck
  class FutureFunctionalityRule < AbstractTextMatchRule
    def self.key
      :future_functionality
    end

    def self.env_name
      "RULE_FUTURE_FUNCTIONALITY"
    end

    def self.friendly_name
      "No future functionality promises"
    end

    def self.description
      "mentioning features or content that is not currently available in your app"
    end

    def lowercased_words_to_look_for
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
