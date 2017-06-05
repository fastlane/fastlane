require 'review/rule'
require 'review/rules/abstract_text_match_rule'

module Review
  class AppleThingsRule < AbstractTextMatchRule
    def self.key
      :apple_things
    end

    def self.env_name
      "RULE_APPLE_THINGS"
    end

    def self.description
      "Don't mention Apple in a negative way"
    end

    def self.lowercased_words_to_look_for
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
