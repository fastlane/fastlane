require_relative '../../helper/plugin_scores_helper.rb'

describe Fastlane::Helper::PluginScoresHelper::FastlaneActionFileParser do
  describe 'parsing' do
    it "parses single line action's description" do
      action_file = './fastlane/spec/fixtures/plugins/single_line_description_action.rb'
      actions = Fastlane::Helper::PluginScoresHelper::FastlaneActionFileParser.new.parse_file(File.expand_path(action_file))
      expect(actions.length).to equal(1)
      expect(actions.first.description).to match('This is single line description.') if actions.length == 1
    end

    it "parses multi line action's description" do
      action_file = './fastlane/spec/fixtures/plugins/multi_line_description_action.rb'
      actions = Fastlane::Helper::PluginScoresHelper::FastlaneActionFileParser.new.parse_file(File.expand_path(action_file))
      expect(actions.length).to equal(1)
      expect(actions.first.description).to match('This is multi line description.') if actions.length == 1
    end
  end
end

describe Fastlane::Helper::PluginScoresHelper::FastlanePluginScore do
  describe ".github_page?" do
    it "accepts a github.com repository" do
      expect(described_class.github_page?("https://github.com/fastlane/fastlane")).to be(true)
    end

    it "rejects hosts that only start with github.com" do
      expect(described_class.github_page?("https://github.com.evil.example/fastlane/fastlane")).to be(false)
      expect(described_class.github_page?("https://github.company.example/fastlane/fastlane")).to be(false)
    end

    it "rejects non https and unparsable homepages" do
      expect(described_class.github_page?("http://github.com/fastlane/fastlane")).to be(false)
      expect(described_class.github_page?("not a url")).to be(false)
      expect(described_class.github_page?(nil)).to be(false)
    end
  end
end
