require_relative 'abstract_text_match_rule'

module Precheck
  class FreeStuffIAPRule < AbstractTextMatchRule
    def self.key
      :free_stuff_in_iap
    end

    def self.env_name
      "RULE_FREE_STUFF_IN_IAP"
    end

    def self.friendly_name
      "No words indicating your IAP is free"
    end

    def self.description
      "using text indicating that your IAP is free"
    end

    def supported_fields_symbol_set
      [:in_app_purchase].to_set
    end

    def lowercased_words_to_look_for
      [
        "free"
      ].map(&:downcase)
    end
  end
end
