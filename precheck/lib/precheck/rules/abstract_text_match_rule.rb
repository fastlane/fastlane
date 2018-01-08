require_relative '../rule'

module Precheck
  # abstract class that defines a default way to check for the presence of a list of words within a block of text
  class AbstractTextMatchRule < TextRule
    WORD_SEARCH_TYPES = {
      fail_on_inclusion: "fail_on_inclusion",
      fail_on_exclusion: "fail_on_exclusion"
    }

    attr_accessor :lowercased_words_to_look_for

    def lowercased_words_to_look_for
      not_implemented(__method__)
    end

    # list of words or phrases that should be excluded from this rule
    # they will be removed from the text string before the rule is executed
    def allowed_lowercased_words
      []
    end

    def pass_if_empty?
      return true
    end

    def word_search_type
      WORD_SEARCH_TYPES[:fail_on_inclusion]
    end

    def remove_safe_words(text: nil)
      text_without_safe_words = text
      allowed_lowercased_words.each do |safe_word|
        text_without_safe_words.gsub!(safe_word, '')
      end
      return text_without_safe_words
    end

    # rule block that checks text for any instance of each string in lowercased_words_to_look_for
    def rule_block
      return lambda { |text|
        text = text.to_s.strip.downcase
        if text.empty?
          if pass_if_empty?
            return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:passed])
          else
            return RuleReturn.new(validation_state: VALIDATION_STATES[:failed], failure_data: "missing text")
          end
        end

        text = remove_safe_words(text: text)

        matches = lowercased_words_to_look_for.each_with_object([]) do |word, found_words|
          if text.include?(word)
            found_words << word
          end
        end

        if matches.length > 0 && word_search_type == WORD_SEARCH_TYPES[:fail_on_inclusion]
          # we are supposed to fail if any of the words are found
          friendly_matches = matches.join(', ')
          UI.verbose("😭  #{self.class.name.split('::').last ||= self.class.name} found words \"#{friendly_matches}\"")

          return RuleReturn.new(validation_state: VALIDATION_STATES[:failed], failure_data: "found: #{friendly_matches}")
        elsif matches.length < lowercased_words_to_look_for.length && word_search_type == WORD_SEARCH_TYPES[:fail_on_exclusion]
          # we are supposed to fail if any of the words are not found (like current copyright date in the copyright field)
          search_data_set = lowercased_words_to_look_for.to_set
          search_data_set.subtract(matches)

          missing_words = search_data_set.to_a.join(', ')
          UI.verbose("😭  #{self.class.name.split('::').last ||= self.class.name} didn't find words \"#{missing_words}\"")

          return RuleReturn.new(validation_state: VALIDATION_STATES[:failed], failure_data: "missing: #{missing_words}")
        else
          return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
        end
      }
    end
  end
end
