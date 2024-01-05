require 'precheck'

module Precheck
  describe Precheck do
    describe Precheck::CopyrightDateRule do
      let(:rule) { CopyrightDateRule.new }
      let(:happy_item) { TextItemToCheck.new("Copyright taquitos, #{DateTime.now.year}", :copyright, "copyright") }
      let(:old_copyright_item) { TextItemToCheck.new("Copyright taquitos, 2016", :copyright, "copyright") }
      let(:empty_copyright_item) { TextItemToCheck.new(nil, :copyright, "copyright") }

      it "passes for current date" do
        result = rule.check_item(happy_item)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      it "skips for fields that aren't copyright" do
        not_copyright_item = TextItemToCheck.new("not copyright", :description, "description")
        result = rule.check_item(not_copyright_item)
        expect(result).to eq(nil)
      end

      it "fails for old date" do
        result = rule.check_item(old_copyright_item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
      end

      it "fails for empty date" do
        result = rule.check_item(empty_copyright_item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
      end
    end
  end
end
