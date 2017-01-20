require 'fastlane/cli_tools_distributor'

describe Fastlane::CLIToolsDistributor do
  it "runs the lane instead of the tool when there is a conflict" do
    FastlaneSpec::Env.with_ARGV(["sigh"]) do
      require 'fastlane/commands_generator'
      expect(FastlaneCore::FastlaneFolder).to receive(:fastfile_path).and_return("./fastlane/spec/fixtures/fastfiles/FastfileUseToolNameAsLane").at_least(:once)
      expect(Fastlane::CommandsGenerator).to receive(:start).and_return(nil)
      Fastlane::CLIToolsDistributor.take_off
    end
  end

  it "runs a separate tool when the tool is available and the name is not used in a lane" do
    FastlaneSpec::Env.with_ARGV(["gym"]) do
      require 'gym/options'
      require 'gym/commands_generator'
      expect(FastlaneCore::FastlaneFolder).to receive(:fastfile_path).and_return("./fastlane/spec/fixtures/fastfiles/FastfileUseToolNameAsLane").at_least(:once)
      expect(Gym::CommandsGenerator).to receive(:start).and_return(nil)
      Fastlane::CLIToolsDistributor.take_off
    end
  end
end
