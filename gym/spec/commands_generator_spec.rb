require 'gym/commands_generator'

describe Gym::CommandsGenerator do
  def expect_manager_work_with(expected_options)
    fake_manager = "manager"
    expect(Gym::Manager).to receive(:new).and_return(fake_manager)
    expect(fake_manager).to receive(:work) do |actual_options|
      expect(expected_options._values).to eq(actual_options._values)
    end
  end

  describe ":build option handling" do
    it "can use the scheme short flag from tool options" do
      # leaving out the command name defaults to 'build'
      stub_commander_runner_args(['-s', 'MyScheme'])

      expected_options = FastlaneCore::Configuration.create(Gym::Options.available_options, { scheme: 'MyScheme' })

      expect_manager_work_with(expected_options)

      Gym::CommandsGenerator.start
    end

    it "can use the clean flag from tool options" do
      # leaving out the command name defaults to 'build'
      stub_commander_runner_args(['--clean', 'true'])

      expected_options = FastlaneCore::Configuration.create(Gym::Options.available_options, { clean: true })

      expect_manager_work_with(expected_options)

      Gym::CommandsGenerator.start
    end
  end

  # :init is not tested here because it does not use any tool options.
end
