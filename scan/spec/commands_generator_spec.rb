require 'scan/commands_generator'

describe Scan::CommandsGenerator do
  let(:available_options) { Scan::Options.available_options }

  describe ":tests option handling" do
    def expect_manager_work_with(expected_options)
      expect(Scan::Manager).to receive_message_chain(:new, :work) do |actual_options|
        expect(actual_options._values).to eq(expected_options._values)
      end
    end

    it "can use the clean short flag from tool options" do
      # leaving out the command name defaults to 'tests'
      stub_commander_runner_args(['-c', 'true'])

      expected_options = FastlaneCore::Configuration.create(available_options, { clean: true })
      expect_manager_work_with(expected_options)

      Scan::CommandsGenerator.start
    end

    it "can use the scheme flag from tool options" do
      # leaving out the command name defaults to 'tests'
      stub_commander_runner_args(['--scheme', 'MyScheme'])

      expected_options = FastlaneCore::Configuration.create(available_options, { scheme: 'MyScheme' })
      expect_manager_work_with(expected_options)

      Scan::CommandsGenerator.start
    end
  end

  # :init is not tested here because it does not use any tool options
end
