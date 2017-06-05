require 'review/rule'
require 'review/rules/abstract_text_match_rule'

module Review
  class OtherPlatformsRule < AbstractTextMatchRule
    def self.key
      :other_platforms
    end

    def self.env_name
      "RULE_OTHER_PLATFORMS"
    end

    def self.description
      "Don't mention other platforms, like Android or Blackberry"
    end

    def self.lowercased_words_to_look_for
      [
        "android",
        "windows phone",
        "tizen",
        "windows 10 mobile",
        "sailfish os",
        "windows universal app",
        "wua",
        "blackberry",
        "palm os",
        "symbian"
      ].map(&:downcase)
    end
  end
end
