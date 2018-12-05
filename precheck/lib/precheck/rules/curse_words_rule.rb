require 'digest'

require_relative '../rule'

module Precheck
  class CurseWordsRule < TextRule
    def self.key
      :curse_words
    end

    def self.env_name
      "RULE_CURSE_WORDS"
    end

    def self.friendly_name
      "No curse words"
    end

    def self.description
      "including words that might be considered objectionable"
    end

    def rule_block
      return lambda { |text|
        return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:passed]) if text.to_s.strip.empty?
        text = text.downcase
        split_words = text.split
        split_words_without_punctuation = text.gsub(/\W/, ' ').split

        # remove punctuation and add only unique words
        all_metadata_words_list = (split_words + split_words_without_punctuation).uniq
        metadata_word_hashes = all_metadata_words_list.map { |word| Digest::SHA256.hexdigest(word) }
        curse_hashes_set = hashed_curse_word_set

        found_words = []
        metadata_word_hashes.each_with_index do |word, index|
          if curse_hashes_set.include?(word)
            found_words << all_metadata_words_list[index]
          end
        end

        if found_words.length > 0
          friendly_found_words = found_words.join(', ')
          UI.verbose("#{self.class.name.split('::').last ||= self.class.name} found potential curse words 😬")
          UI.verbose("Keep in mind, these words might be ok given the context they are used in")
          UI.verbose("Matched: \"#{friendly_found_words}\"")
          return RuleReturn.new(validation_state: VALIDATION_STATES[:failed], failure_data: "found: #{friendly_found_words}")
        else
          return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
        end
      }
    end

    def hashed_curse_word_set
      curse_hashes = []
      File.open(File.dirname(__FILE__) + '/rules_data/curse_word_hashes/en_us.txt').each do |line|
        curse_hashes << line.to_s.strip
      end
      return curse_hashes.to_set
    end
  end
end
