require 'os'

describe Snapshot do
  describe Snapshot::Runner do
    let(:runner) { Snapshot::Runner.new }
    describe 'Parses embedded SnapshotHelper.swift' do
      it 'finds the current embedded version' do
        allow(FastlaneCore::Helper).to receive(:xcode_at_least?).with("9.0").and_return(true)

        helper_version = runner.version_of_bundled_helper
        expect(helper_version).to match(/^SnapshotHelperVersion \[\d.\d\]$/)
      end
    end
    describe 'Parses embedded SnapshotHelperXcode8.swift' do
      it 'finds the current embedded version' do
        allow(FastlaneCore::Helper).to receive(:xcode_at_least?).with("9.0").and_return(false)

        helper_version = runner.version_of_bundled_helper
        expect(helper_version).to match(/^SnapshotHelperXcode8Version \[\d.\d\]$/)
      end
    end

    describe 'Decides on the number of sims to launch when simultaneously snapshotting' do
      it 'returns 1 if CPUs is 1' do
        snapshot_config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, {})
        launcher_config = Snapshot::SimulatorLauncherConfiguration.new(snapshot_config: snapshot_config)
        allow(Snapshot::CPUInspector).to receive(:cpu_count).and_return(1)

        sims = Snapshot::SimulatorLauncher.new(launcher_configuration: launcher_config).default_number_of_simultaneous_simulators
        expect(sims).to eq(1)
      end

      it 'returns 2 if CPUs is 2' do
        snapshot_config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, {})
        launcher_config = Snapshot::SimulatorLauncherConfiguration.new(snapshot_config: snapshot_config)
        allow(Snapshot::CPUInspector).to receive(:cpu_count).and_return(2)

        sims = Snapshot::SimulatorLauncher.new(launcher_configuration: launcher_config).default_number_of_simultaneous_simulators
        expect(sims).to eq(2)
      end

      it 'returns 3 if CPUs is 4' do
        snapshot_config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, {})
        launcher_config = Snapshot::SimulatorLauncherConfiguration.new(snapshot_config: snapshot_config)
        allow(Snapshot::CPUInspector).to receive(:cpu_count).and_return(4)

        sims = Snapshot::SimulatorLauncher.new(launcher_configuration: launcher_config).default_number_of_simultaneous_simulators
        expect(sims).to eq(3)
      end
    end
  end
end
