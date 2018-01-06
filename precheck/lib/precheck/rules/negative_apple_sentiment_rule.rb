require_relative 'abstract_text_match_rule'

module Precheck
  class NegativeAppleSentimentRule < AbstractTextMatchRule
    def self.key
      :negative_apple_sentiment
    end

    def self.env_name
      "RULE_NEGATIVE_APPLE_SENTIMENT"
    end

    def self.friendly_name
      "No negative  sentiment"
    end

    def self.description
      "mentioning  in a way that could be considered negative"
    end

    def lowercased_words_to_look_for
      [
        "ios",
        "macos",
        "safari",
        "webkit",
        "uikit",
        "apple store"
      ].map { |word| (word + " bug").downcase } +
        [
          "slow iphone",
          "slow ipad",
          "old iphone"
        ]
    end
  end
end
