require 'precheck/rule'
require 'precheck/rules/abstract_text_match_rule'

module Precheck
  class PreReleaseAppleSoftwareHardware < AbstractTextMatchRule
    def self.key
      :pre_release_apple_sw_hw
    end

    def self.env_name
      "RULE_PRE_RELEASE_APPLE_SW_HW"
    end

    def self.friendly_name
      "No words containing pre-release Apple software or hardware"
    end

    def self.description
      "mentioning any pre-release Apple software or hardware"
    end

    def lowercased_words_to_look_for
      [
        "iPhone X"
      ].map(&:downcase)
    end
  end
end
