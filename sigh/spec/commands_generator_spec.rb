require 'sigh/commands_generator'

def expect_resign_run(options)
  expect(resign).to receive(:run) do |actual_options, actual_args|
    expect(actual_options).to match_commander_options(options)
    expect(actual_args).to eq([])
  end
end

describe Sigh::CommandsGenerator do
  describe "resign option handling" do
    let(:resign) do
      resign = Sigh::Resign.new
      expect(Sigh::Resign).to receive(:new).and_return(resign)
      resign
    end

    it "signing_identity short flag is not shadowed by cert_id short flag from tool options" do
      stub_commander_runner_args(['resign', '-i', 'abcd'])

      options = Commander::Command::Options.new
      options.signing_identity = 'abcd'

      expect_resign_run(options)

      Sigh::CommandsGenerator.start
    end

    it "provisioning_profile short flag is not shadowed by platform short flag from tool options" do
      stub_commander_runner_args(['resign', '-p', 'abcd'])

      options = Commander::Command::Options.new
      options.provisioning_profile = [['abcd']]

      expect_resign_run(options)

      Sigh::CommandsGenerator.start
    end
  end

  describe "renew option handling" do
    it "cert_id short flag from tool options can be used" do
      # leaving out the command name defaults to 'renew'
      stub_commander_runner_args(['-i', 'abcd'])

      expect(Sigh::Manager).to receive(:start)

      Sigh::CommandsGenerator.start

      expect(Sigh.config[:cert_id]).to eq('abcd')
    end

    it "platform short flag is not shadowed by cert_id short flag from tool options" do
      # leaving out the command name defaults to 'renew'
      stub_commander_runner_args(['-p', 'tvos'])

      expect(Sigh::Manager).to receive(:start)

      Sigh::CommandsGenerator.start

      expect(Sigh.config[:platform]).to eq('tvos')
    end
  end
end
