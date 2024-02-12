require_relative '../../helper/tool_name_formatting_helper.rb'

describe Fastlane::Helper::ToolNameFormattingHelper do
  let(:fixture_path) { 'fastlane/spec/fixtures/fastfiles/tool_name_formatting.txt' }
  before(:each) do
    @helper = Fastlane::Helper::ToolNameFormattingHelper.new(path: fixture_path, is_documenting_invalid_examples: true)
  end

  describe 'when parsing fixture file' do
    it 'should match array of expected errors' do
      expected_errors = [
        "fastlane tools have to be formatted in lowercase: fastlane in '#{fixture_path}:17': FastLane makes code signing management easy.",
        "fastlane tools have to be formatted in lowercase: fastlane in '#{fixture_path}:18': Fastlane makes code signing management easy.",
        "fastlane tools have to be formatted in lowercase: fastlane in '#{fixture_path}:19': _FastLane_ makes code signing management easy.",
        "fastlane tools have to be formatted in lowercase: fastlane in '#{fixture_path}:23': A sentence that contains a _FastLane_ keyword, but also an env var: `FASTLANE_SKIP_CHANGELOG`."
      ]
      expect(@helper.find_tool_name_formatting_errors).to match_array(expected_errors)
    end
  end
end
