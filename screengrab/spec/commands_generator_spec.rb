require 'screengrab/commands_generator'

describe Screengrab::CommandsGenerator do
  let(:available_options) { Screengrab::Options.available_options }

  describe ":run option handling" do
    def expect_runner_run_with(android_home)
      allow(Screengrab::DetectValues).to receive(:set_additional_default_values)
      expect(Screengrab::AndroidEnvironment).to receive(:new).with(android_home, nil)
      allow(Screengrab::DependencyChecker).to receive(:check)
      expect(Screengrab::Runner).to receive_message_chain(:new, :run)
    end

    it "can use the android_home short flag from tool options" do
      # leaving out the command name defaults to 'run'
      stub_commander_runner_args(['-n', 'home/path'])

      expect_runner_run_with('home/path')

      Screengrab::CommandsGenerator.start
    end

    it "can use the output_directory flag from tool options" do
      # leaving out the command name defaults to 'run'
      stub_commander_runner_args(['-n', 'home/path', '--output_directory', 'output/dir'])

      expect_runner_run_with('home/path')

      Screengrab::CommandsGenerator.start

      expect(Screengrab.config[:output_directory]).to eq('output/dir')
    end
  end

  # :init is not tested here because it does not use any tool options
end
