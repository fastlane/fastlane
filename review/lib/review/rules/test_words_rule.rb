require 'review/rule'
require 'review/rules/abstract_text_match_rule'

module Review
  class TestWordsRule < AbstractTextMatchRule
    def self.key
      :test_words
    end

    def self.env_name
      "RULE_TEST_WORDS"
    end

    def self.description
      "Don't use text indicating this release is a test and not an App Store ready build"
    end

    def self.lowercased_words_to_look_for
      [
        "testing",
        "just a test",
        "alpha test",
        "beta test"
      ].map(&:downcase)
    end
  end
end
