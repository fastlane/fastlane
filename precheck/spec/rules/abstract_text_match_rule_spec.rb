require 'precheck'

module Precheck
  # all the stuff we need that doesn't matter for testing
  class TestingRule < AbstractTextMatchRule
    def self.key
      return :test_rule_key
    end

    def self.env_name
      return "JUST_A_TEST_RULE"
    end

    def self.description
      return "test descriptions"
    end
  end

  # always pass as long as these words are found
  class FailOnExclusionTestingTextMatchRule < TestingRule
    def lowercased_words_to_look_for
      ["tacos", "taquitos"].map(&:downcase)
    end

    def word_search_type
      WORD_SEARCH_TYPES[:fail_on_exclusion]
    end
  end

  # always pass as long as these words are not found
  class PassOnExclusionOrEmptyTestingTextMatchRule < TestingRule
    def lowercased_words_to_look_for
      ["tacos", "puppies"].map(&:downcase)
    end
  end

  # always fail as long as any of these words are found
  class PassOnExclusionTestingTextMatchRule < TestingRule
    def lowercased_words_to_look_for
      ["tacos", "puppies", "taquitos"].map(&:downcase)
    end

    def pass_if_empty?
      return false
    end
  end

  describe Precheck do
    describe Precheck::AbstractTextMatchRule do
      let(:fail_on_exclusion_rule) { FailOnExclusionTestingTextMatchRule.new }
      let(:pass_on_exclusion_or_empty_rule) { PassOnExclusionOrEmptyTestingTextMatchRule.new }
      let(:pass_on_exclusion_rule) { PassOnExclusionTestingTextMatchRule.new }
      # let(:inclusion_rule) { InclusionTestingTextMatchRule.new() }

      # pass on exclusion or empty tests
      it "ensures string is flagged if words found in exclusion rule" do
        item = TextItemToCheck.new("tacos are really delicious and puppies shouldn't eat them.", :description, "description")
        result = pass_on_exclusion_or_empty_rule.check_item(item)

        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.rule_return.failure_data).to eq("found: tacos, puppies")
      end

      it "ensures string is flagged if words found in exclusion rule ignoring capitalization" do
        item = TextItemToCheck.new("TaCoS are really delicious and PupPies shouldn't eat them.", :description, "description")
        result = pass_on_exclusion_or_empty_rule.check_item(item)

        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.rule_return.failure_data).to eq("found: tacos, puppies")
      end

      it "ensures string is flagged if even one word is found in exclusion rule" do
        item = TextItemToCheck.new("I think puppies are the best", :description, "description")
        result = pass_on_exclusion_or_empty_rule.check_item(item)

        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.rule_return.failure_data).to eq("found: puppies")
      end

      it "ensures passing if text item is nil" do
        item = TextItemToCheck.new(nil, :description, "description")
        result = pass_on_exclusion_or_empty_rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      it "ensures passing if text item is empty" do
        item = TextItemToCheck.new("", :description, "description")
        result = pass_on_exclusion_or_empty_rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      # pass on exclusion, but fail on empty or nil
      it "ensures failing if text item is nil pass_if_empty? is false" do
        item = TextItemToCheck.new(nil, :description, "description")
        result = pass_on_exclusion_rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
      end

      it "ensures failing if text item is empty when pass_if_empty? is false" do
        item = TextItemToCheck.new("", :description, "description")
        result = pass_on_exclusion_rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
      end

      it "ensures failing if text item is empty when pass_if_empty? is false" do
        item = TextItemToCheck.new("", :description, "description")
        result = pass_on_exclusion_rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
      end

      # fail on exclusion tests
      it "ensures string is not flagged if all words are found in fail_on_exclusion rule" do
        item = TextItemToCheck.new("tacos and taquitos are really delicious, too bad I'm vegetarian now", :description, "description")
        result = fail_on_exclusion_rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      it "ensures string is flagged if missing some words in fail_on_exclusion rule" do
        item = TextItemToCheck.new("tacos are really delicious, too bad I'm vegetarian now", :description, "description")
        result = fail_on_exclusion_rule.check_item(item)

        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.rule_return.failure_data).to eq("missing: taquitos")
      end
    end
  end
end
