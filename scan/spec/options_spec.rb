describe Scan::Options do
  it "does not prelaunch the simulator when FASTLANE_EXPLICIT_OPEN_SIMULATOR is 0" do
    FastlaneSpec::Env.with_env_values('FASTLANE_EXPLICIT_OPEN_SIMULATOR' => '0') do
      config = FastlaneCore::Configuration.create(Scan::Options.available_options, {})
      expect(config[:prelaunch_simulator]).to eq(false)
    end
  end

  describe "include_simulator_logs" do
    def include_simulator_logs(value)
      FastlaneCore::Configuration.create(Scan::Options.available_options, { include_simulator_logs: value })[:include_simulator_logs]
    end

    it "still reads true and false given as strings as Booleans" do
      expect(include_simulator_logs('true')).to be(true)
      expect(include_simulator_logs('false')).to be(false)
    end

    it "reads on-failure from SCAN_INCLUDE_SIMULATOR_LOGS" do
      FastlaneSpec::Env.with_env_values('SCAN_INCLUDE_SIMULATOR_LOGS' => 'on-failure') do
        config = FastlaneCore::Configuration.create(Scan::Options.available_options, {})
        expect(config[:include_simulator_logs]).to eq('on-failure')
      end
    end

    it "rejects any other value" do
      expect do
        include_simulator_logs('sometimes')
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "Unsupported include_simulator_logs 'sometimes', must be: true, false, on-failure")
    end
  end
end
