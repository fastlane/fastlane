require 'precheck/rule'
require 'precheck/rules/abstract_text_match_rule'

module Precheck
  class AppleThingsRule < AbstractTextMatchRule
    def self.key
      :apple_things
    end

    def self.env_name
      "RULE_APPLE_THINGS"
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
