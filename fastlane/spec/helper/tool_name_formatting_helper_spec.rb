require_relative '../../helper/tool_name_formatting_helper.rb'

describe Fastlane::Helper::ToolNameFormattingHelper do
  before(:each) do
    content = File.read("fastlane/spec/fixtures/fastfiles/tool_name_formatting.txt")
    @helper = Fastlane::Helper::ToolNameFormattingHelper.new(content: content, path: "CONTRIBUTING.md")
  end

  describe "when parsing fixture file" do
    it "should match array of expected errors" do
      expected_errors = [
        "fastlane tools have to be formatted in lowercase: fastlane in 'CONTRIBUTING.md:19': _FastLane_ makes code signing management easy. ❌",
        "fastlane tools have to be formatted in lowercase: fastlane in 'CONTRIBUTING.md:23': A sentence that contains a _FastLane_ keyword, but also an env var: `FASTLANE_SKIP_CHANGELOG`. ❌"
      ]
      expect(@helper.find_tool_name_formatting_errors).to match_array(expected_errors)
    end
  end
end
