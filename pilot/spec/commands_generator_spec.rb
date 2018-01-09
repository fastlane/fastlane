require 'pilot/commands_generator'

describe Pilot::CommandsGenerator do
  let(:available_options) { Pilot::Options.available_options }

  def expect_build_manager_call_with(method_sym, expected_options)
    fake_build_manager = "build_manager"
    expect(Pilot::BuildManager).to receive(:new).and_return(fake_build_manager)
    expect(fake_build_manager).to receive(method_sym) do |actual_options|
      expect(actual_options._values).to eq(expected_options._values)
    end
  end

  {
    upload: :upload,
    distribute: :distribute,
    builds: :list
  }.each do |command, build_manager_method|
    describe ":#{command} option handling" do
      it "can use the username short flag from tool options" do
        stub_commander_runner_args([command.to_s, '-u', 'me@it.com'])

        expected_options = FastlaneCore::Configuration.create(available_options, { username: 'me@it.com' })
        expect_build_manager_call_with(build_manager_method, expected_options)

        Pilot::CommandsGenerator.start
      end

      it "can use the app_identifier flag from tool options" do
        stub_commander_runner_args([command.to_s, '--app_identifier', 'your.awesome.App'])

        expected_options = FastlaneCore::Configuration.create(available_options, { app_identifier: 'your.awesome.App' })
        expect_build_manager_call_with(build_manager_method, expected_options)

        Pilot::CommandsGenerator.start
      end
    end
  end

  def expect_tester_manager_call_with(method_sym, expected_options_sets)
    expected_options_sets = [expected_options_sets] unless expected_options_sets.kind_of?(Array)

    fake_tester_manager = "tester_manager"
    expect(Pilot::TesterManager).to receive(:new).and_return(fake_tester_manager)
    expected_options_sets.each do |expected_options|
      expect(fake_tester_manager).to receive(method_sym) do |actual_options|
        expect(actual_options._values).to eq(expected_options._values)
      end
    end
  end

  describe ":list option handling" do
    it "can use the username short flag from tool options" do
      stub_commander_runner_args(['list', '-u', 'me@it.com'])

      expected_options = FastlaneCore::Configuration.create(available_options, { username: 'me@it.com' })
      expect_tester_manager_call_with(:list_testers, expected_options)

      Pilot::CommandsGenerator.start
    end

    it "can use the app_identifier flag from tool options" do
      stub_commander_runner_args(['list', '--app_identifier', 'your.awesome.App'])

      expected_options = FastlaneCore::Configuration.create(available_options, { app_identifier: 'your.awesome.App' })
      expect_tester_manager_call_with(:list_testers, expected_options)

      Pilot::CommandsGenerator.start
    end
  end

  {
    add: :add_tester,
    remove: :remove_tester,
    find: :find_tester
  }.each do |command, tester_manager_method|
    describe ":#{command} option handling" do
      it "can use the email short flag from tool options" do
        stub_commander_runner_args([command.to_s, '-e', 'you@that.com'])

        expected_options = FastlaneCore::Configuration.create(available_options, { email: 'you@that.com' })
        expect_tester_manager_call_with(tester_manager_method, expected_options)

        Pilot::CommandsGenerator.start
      end

      it "can use the email flag from tool options" do
        stub_commander_runner_args([command.to_s, '--email', 'you@that.com'])

        expected_options = FastlaneCore::Configuration.create(available_options, { email: 'you@that.com' })
        expect_tester_manager_call_with(tester_manager_method, expected_options)

        Pilot::CommandsGenerator.start
      end

      it "can provide multiple emails as args" do
        stub_commander_runner_args([command.to_s, 'you@that.com', 'another@that.com'])

        expected_options1 = FastlaneCore::Configuration.create(available_options, { email: 'you@that.com' })
        expected_options2 = FastlaneCore::Configuration.create(available_options, { email: 'another@that.com' })
        expect_tester_manager_call_with(tester_manager_method, [expected_options1, expected_options2])

        Pilot::CommandsGenerator.start
      end
    end
  end

  describe ":export option handling" do
    def expect_tester_exporter_export_testers_with(expected_options)
      fake_tester_exporter = "tester_exporter"
      expect(Pilot::TesterExporter).to receive(:new).and_return(fake_tester_exporter)
      expect(fake_tester_exporter).to receive(:export_testers) do |actual_options|
        expect(actual_options._values).to eq(expected_options._values)
      end
    end

    it "can use the testers_file_path short flag from tool options" do
      stub_commander_runner_args(['export', '-c', 'file/path'])

      expected_options = FastlaneCore::Configuration.create(available_options, { testers_file_path: 'file/path' })
      expect_tester_exporter_export_testers_with(expected_options)

      Pilot::CommandsGenerator.start
    end

    it "can use the app_identifier flag from tool options" do
      stub_commander_runner_args(['export', '--app_identifier', 'your.awesome.App'])

      expected_options = FastlaneCore::Configuration.create(available_options, { app_identifier: 'your.awesome.App' })
      expect_tester_exporter_export_testers_with(expected_options)

      Pilot::CommandsGenerator.start
    end
  end

  describe ":import option handling" do
    def expect_tester_importer_import_testers_with(expected_options)
      fake_tester_importer = "tester_importer"
      expect(Pilot::TesterImporter).to receive(:new).and_return(fake_tester_importer)
      expect(fake_tester_importer).to receive(:import_testers) do |actual_options|
        expect(actual_options._values).to eq(expected_options._values)
      end
    end

    it "can use the testers_file_path short flag from tool options" do
      stub_commander_runner_args(['import', '-c', 'file/path'])

      expected_options = FastlaneCore::Configuration.create(available_options, { testers_file_path: 'file/path' })
      expect_tester_importer_import_testers_with(expected_options)

      Pilot::CommandsGenerator.start
    end

    it "can use the app_identifier flag from tool options" do
      stub_commander_runner_args(['import', '--app_identifier', 'your.awesome.App'])

      expected_options = FastlaneCore::Configuration.create(available_options, { app_identifier: 'your.awesome.App' })
      expect_tester_importer_import_testers_with(expected_options)

      Pilot::CommandsGenerator.start
    end
  end
end
