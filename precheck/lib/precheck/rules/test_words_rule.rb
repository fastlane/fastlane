require_relative 'abstract_text_match_rule'

module Precheck
  class TestWordsRule < AbstractTextMatchRule
    def self.key
      :test_words
    end

    def self.env_name
      "RULE_TEST_WORDS"
    end

    def self.friendly_name
      "No words indicating test content"
    end

    def self.description
      "using text indicating this release is a test"
    end

    def lowercased_words_to_look_for
      [
        "testing",
        "just a test",
        "alpha test",
        "beta test"
      ].map(&:downcase)
    end
  end
end
