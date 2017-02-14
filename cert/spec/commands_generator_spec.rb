require 'cert/commands_generator'

describe Cert::CommandsGenerator do
  let(:runner) do
    runner = Cert::Runner.new
    expect(Cert::Runner).to receive(:new).and_return(runner)
    runner
  end

  describe ":create option handling" do
    it "username short flag from tool options can be used" do
      # leaving out the command name defaults to 'create'
      stub_commander_runner_args(['-u', 'me@it.com'])

      # launch takes no params, but we want to expect the call and prevent
      # actual execution of the method
      expect(runner).to receive(:launch)

      Cert::CommandsGenerator.start

      expect(Cert.config[:username]).to eq('me@it.com')
    end

    it "platform flag from tool options can be used" do
      # leaving out the command name defaults to 'create'
      stub_commander_runner_args(['--platform', 'macos'])

      # launch takes no params, but we want to expect the call and prevent
      # actual execution of the method
      expect(runner).to receive(:launch)

      Cert::CommandsGenerator.start

      expect(Cert.config[:platform]).to eq('macos')
    end
  end

  describe ":revoke_expired option handling" do
    it "development flag from tool options can be used" do
      stub_commander_runner_args(['revoke_expired', '--development', 'true'])

      # revoke_expired_certs! takes no params, but we want to expect the call
      # and prevent actual execution of the method
      expect(runner).to receive(:revoke_expired_certs!)

      Cert::CommandsGenerator.start

      expect(Cert.config[:development]).to be(true)
    end

    it "output_path short flag from tool options can be used" do
      stub_commander_runner_args(['revoke_expired', '-o', 'output/path'])

      # revoke_expired_certs! takes no params, but we want to expect the call
      # and prevent actual execution of the method
      expect(runner).to receive(:revoke_expired_certs!)

      Cert::CommandsGenerator.start

      expect(Cert.config[:output_path]).to eq('output/path')
    end
  end
end
