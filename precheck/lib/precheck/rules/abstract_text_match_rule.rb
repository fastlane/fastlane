require 'precheck/rule'

module Precheck
  # abstract class that defines a default way to check for the presence of a list of words within a block of text
  class AbstractTextMatchRule < TextRule
    def self.lowercased_words_to_look_for
      not_implemented(__method__)
    end

    # rule block that checks text for any instance of each string in self.lowercased_words_to_look_for
    def self.rule_block
      return lambda { |text|
        text = text.to_s.strip.downcase
        return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:pass]) if text.empty?

        matches = self.lowercased_words_to_look_for.each_with_object([]) do |word, found_words|
          if text.include?(word)
            found_words << word
          end
        end

        if matches.length > 0
          friendly_matches = matches.join(', ')
          UI.verbose "😭  #{self.name.split('::').last ||= self.name} found words \"#{friendly_matches}\""
          return RuleReturn.new(validation_state: VALIDATION_STATES[:fail], failure_data: "found: #{friendly_matches}")
        else
          return RuleReturn.new(validation_state: VALIDATION_STATES[:pass])
        end
      }
    end
  end
end
