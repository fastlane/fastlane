require 'digest'
require 'review/rule'

module Review
  class CurseWordsRule < TextRule
    def self.key
      :curse_words
    end

    def self.env_name
      "RULE_CURSE_WORDS"
    end

    def self.description
      "Find words that might be considered objectionable"
    end

    # rule block that checks text for any instance of each string in self.lowercased_words_to_look_for
    def self.rule_block
      return lambda { |text|
        return Review::VALIDATION_STATES[:pass] if text.to_s.strip.empty?

        all_metadata_words_list = text.to_s.downcase.split
        metadata_word_hashes = all_metadata_words_list.map { |word| Digest::SHA256.hexdigest(word) }
        curse_hashes_set = self.hashed_curse_word_set

        found_words = []
        metadata_word_hashes.each_with_index do |word, index|
          if curse_hashes_set.include?(word)
            found_words << all_metadata_words_list[index]
          end
        end

        if found_words.length > 0
          class_name = self.name.split('::').last ||= self.name
          UI.error "#{class_name} found potential curse words 😬"
          UI.error "Keep in mind, these words might be ok given the context they are used in"
          UI.error "Matched: \"#{found_words.join(', ')}\""
          return Review::VALIDATION_STATES[:fail]
        else
          return Review::VALIDATION_STATES[:pass]
        end
      }
    end

    def self.hashed_curse_word_set
      curse_hashes = []
      File.open(File.dirname(__FILE__) + '/rules_data/curse_word_hashes/en_us.txt').each do |line|
        curse_hashes << line.to_s.strip
      end
      return curse_hashes.to_set
    end
  end
end
