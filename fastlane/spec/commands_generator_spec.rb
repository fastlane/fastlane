require 'fastlane/commands_generator'

describe Fastlane::CommandsGenerator do
  before(:each) do
    ENV['DOTENV'] = nil
    fastlane_folder = File.absolute_path('./fastlane/spec/fixtures/dotenvs/withFastfiles/parentonly/fastlane')
    allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(fastlane_folder)
    allow(FastlaneCore::Env).to receive(:truthy?).and_return(:default)
    allow(FastlaneCore::Env).to receive(:truthy?).with('FASTLANE_SKIP_DOCS').and_return(true)
  end

  describe ":trigger option handling" do
    it "can use the env flag from tool options" do
      stub_commander_runner_args(['command_test', '--env', 'DOTENV'])
      Fastlane::CommandsGenerator.start

      expect(ENV['DOTENV']).to eq('parent')
    end
  end

  describe ":list option handling" do
    it "cannot use the env flag from tool options" do
      stub_commander_runner_args(['list', '--env', 'DOTENV'])
      expect do
        Fastlane::CommandsGenerator.start
      end.to raise_exception(OptionParser::InvalidOption, 'invalid option: --env')

      expect(ENV['DOTENV']).to be_nil
    end
  end
end
