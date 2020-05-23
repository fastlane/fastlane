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
