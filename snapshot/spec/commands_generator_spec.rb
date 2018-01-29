require 'snapshot/commands_generator'
require 'snapshot/reset_simulators'

describe Snapshot::CommandsGenerator do
  let(:available_options) { Snapshot::Options.available_options }

  describe ":run option handling" do
    def expect_runner_work
      allow(Snapshot::DetectValues).to receive(:set_additional_default_values)
      allow(Snapshot::DependencyChecker).to receive(:check_simulators)
      expect(Snapshot::Runner).to receive_message_chain(:new, :work)
    end

    it "can use the languages short flag from tool options" do
      # leaving out the command name defaults to 'run'
      stub_commander_runner_args(['-g', 'en-US,fr-FR'])

      expect_runner_work

      Snapshot::CommandsGenerator.start

      expect(Snapshot.config[:languages]).to eq(['en-US', 'fr-FR'])
    end

    it "can use the output_directory flag from tool options" do
      # leaving out the command name defaults to 'run'
      stub_commander_runner_args(['--output_directory', 'output/dir'])

      expect_runner_work

      Snapshot::CommandsGenerator.start

      expect(Snapshot.config[:output_directory]).to eq('output/dir')
    end
  end

  describe ":reset_simulators option handling" do
    it "can use the ios_version short flag", requires_xcodebuild: true do
      stub_commander_runner_args(['reset_simulators', '-i', '9.3.5,10.0'])

      allow(Snapshot::DetectValues).to receive(:set_additional_default_values)
      expect(Snapshot::ResetSimulators).to receive(:clear_everything!).with(['9.3.5', '10.0'], nil)

      Snapshot::CommandsGenerator.start
    end

    it "can use the ios_version flag", requires_xcodebuild: true do
      stub_commander_runner_args(['reset_simulators', '--ios_version', '9.3.5,10.0'])

      allow(Snapshot::DetectValues).to receive(:set_additional_default_values)
      expect(Snapshot::ResetSimulators).to receive(:clear_everything!).with(['9.3.5', '10.0'], nil)

      Snapshot::CommandsGenerator.start
    end

    it "can use the force flag", requires_xcodebuild: true do
      stub_commander_runner_args(['reset_simulators', '--ios_version', '9.3.5,10.0', '--force'])

      allow(Snapshot::DetectValues).to receive(:set_additional_default_values)
      expect(Snapshot::ResetSimulators).to receive(:clear_everything!).with(['9.3.5', '10.0'], true)

      Snapshot::CommandsGenerator.start
    end
  end

  describe ":clear_derived_data option handling" do
    def allow_path_check
      allow(Snapshot::DetectValues).to receive(:set_additional_default_values)
      allow(Dir).to receive(:exist?).with('data/path').and_return(false)
      allow(Snapshot::UI).to receive(:important)
    end

    it "can use the output_directory short flag from tool options" do
      stub_commander_runner_args(['clear_derived_data', '-f', 'data/path'])

      allow_path_check

      Snapshot::CommandsGenerator.start

      expect(Snapshot.config[:derived_data_path]).to eq('data/path')
    end

    it "can use the output_directory flag from tool options" do
      stub_commander_runner_args(['clear_derived_data', '--derived_data_path', 'data/path'])

      allow_path_check

      Snapshot::CommandsGenerator.start

      expect(Snapshot.config[:derived_data_path]).to eq('data/path')
    end
  end

  # :init and :update are not tested here because they do not use any options
end
