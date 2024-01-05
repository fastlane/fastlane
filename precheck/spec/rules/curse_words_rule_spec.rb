require 'precheck'

module Precheck
  describe Precheck do
    describe Precheck::CurseWordsRule do
      let(:rule) { CurseWordsRule.new }
      let(:happy_item) { TextItemToCheck.new("tacos are really delicious, seriously, I can't even", :description, "description") }
      let(:curse_item) { TextItemToCheck.new("please excuse the use of 'shit' in this description", :description, "description") }

      it "passes for non-curse item" do
        result = rule.check_item(happy_item)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      it "fails for curse word" do
        result = rule.check_item(curse_item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
      end
    end
  end
end
