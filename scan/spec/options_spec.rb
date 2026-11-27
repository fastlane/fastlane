describe Scan::Options do
  it "does not prelaunch the simulator when FASTLANE_EXPLICIT_OPEN_SIMULATOR is 0" do
    FastlaneSpec::Env.with_env_values('FASTLANE_EXPLICIT_OPEN_SIMULATOR' => '0') do
      config = FastlaneCore::Configuration.create(Scan::Options.available_options, {})
      expect(config[:prelaunch_simulator]).to eq(false)
    end
  end
end
