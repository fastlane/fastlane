describe FastlaneCore::ToolCollector do
  before(:all) { ENV.delete("FASTLANE_OPT_OUT_USAGE") }

  let(:collector) { FastlaneCore::ToolCollector.new }

  it "keeps track of what tools get invoked" do
    collector.did_launch_action(:scan)

    expect(collector.launches[:scan]).to eq(1)
    expect(collector.launches[:gym]).to eq(0)
  end

  it "tracks which tool raises an error" do
    collector.did_raise_error(:scan)

    expect(collector.error).to eq(:scan)
    expect(collector.crash).to be(false)
  end

  it "tracks which tool crashes" do
    collector.did_crash(:scan)

    expect(collector.error).to eq(:scan)
    expect(collector.crash).to be(true)
  end

  it "does not post the collected data if the opt-out ENV var is set" do
    with_env_values('FASTLANE_OPT_OUT_USAGE' => '1') do
      collector.did_launch_action(:scan)
      expect(collector.did_finish).to eq(false)
    end
  end

  describe "#name_to_track" do
    it "returns the original name when it's a built-in action" do
      expect(collector.name_to_track(:fastlane)).to eq(:fastlane)
    end

    it "returns nil when it's an external action" do
      expect(collector).to receive(:is_official?).and_return(false)
      expect(collector.name_to_track(:fastlane)).to eq(nil)
    end
  end

  it "posts the collected data with a crash when finished" do
    collector.did_launch_action(:gym)
    collector.did_launch_action(:scan)
    collector.did_crash(:scan)

    analytic_event_body = collector.create_analytic_event_body
    analytics = JSON.parse(analytic_event_body)['analytics']

    expect(analytics.size).to eq(4)
    expect(analytics.find_all { |a| a['primary_target']['detail'] == '1' && a['actor']['detail'] == 'scan' }.size).to eq(1)
    expect(analytics.find_all { |a| a['primary_target']['detail'] == '1' && a['actor']['detail'] == 'gym' }.size).to eq(1)
    expect(analytics.find_all { |a| a['secondary_target']['detail'] == Fastlane::VERSION && a['actor']['detail'] == 'scan' }.size).to eq(2)
    expect(analytics.find_all { |a| a['secondary_target']['detail'] == Fastlane::VERSION && a['actor']['detail'] == 'gym' }.size).to eq(2)
    expect(analytics.find_all { |a| a['primary_target']['detail'] == 'crash' && a['actor']['detail'] == 'scan' }.size).to eq(1)
    expect(analytics.find_all { |a| a['primary_target']['detail'] == 'success' && a['actor']['detail'] == 'gym' }.size).to eq(1)
  end

  it "posts the collected data with an error when finished" do
    collector.did_launch_action(:gym)
    collector.did_launch_action(:scan)
    collector.did_raise_error(:scan)

    analytic_event_body = collector.create_analytic_event_body
    analytics = JSON.parse(analytic_event_body)['analytics']

    expect(analytics.size).to eq(4)
    expect(analytics.find_all { |a| a['primary_target']['detail'] == '1' && a['actor']['detail'] == 'scan' }.size).to eq(1)
    expect(analytics.find_all { |a| a['primary_target']['detail'] == '1' && a['actor']['detail'] == 'gym' }.size).to eq(1)
    expect(analytics.find_all { |a| a['secondary_target']['detail'] == Fastlane::VERSION && a['actor']['detail'] == 'scan' }.size).to eq(2)
    expect(analytics.find_all { |a| a['secondary_target']['detail'] == Fastlane::VERSION && a['actor']['detail'] == 'gym' }.size).to eq(2)
    expect(analytics.find_all { |a| a['primary_target']['detail'] == 'error' && a['actor']['detail'] == 'scan' }.size).to eq(1)
    expect(analytics.find_all { |a| a['primary_target']['detail'] == 'success' && a['actor']['detail'] == 'gym' }.size).to eq(1)
  end

  it "posts the web onboarding data with a success when finished" do
    with_env_values('GENERATED_FASTFILE_ID' => 'fastfile_id') do
      collector.did_launch_action(:fastlane)

      analytic_event_body = collector.create_analytic_event_body
      analytics = JSON.parse(analytic_event_body)['analytics']

      expect(analytics.size).to eq(3)
      expect(analytics.find_all { |a| a['primary_target']['detail'] == '1' && a['actor']['detail'] == 'fastlane' }.size).to eq(1)
      expect(analytics.find_all { |a| a['event_source']['product'] != 'fastlane_web_onboarding' && a['secondary_target']['detail'] == Fastlane::VERSION && a['actor']['detail'] == 'fastlane' }.size).to eq(2)
      expect(analytics.find_all { |a| a['primary_target']['detail'] == 'success' && a['actor']['detail'] == 'fastlane' }.size).to eq(1)
      expect(analytics.find_all { |a| a['action']['name'] == 'fastfile_executed' && a['actor']['detail'] == 'fastfile_id' && a['primary_target']['detail'] == 'success' }.size).to eq(1)
    end
  end

  it "posts the web onboarding data with an crash when finished" do
    with_env_values('GENERATED_FASTFILE_ID' => 'fastfile_id') do
      collector.did_launch_action(:fastlane)
      collector.did_crash(:gym)

      analytic_event_body = collector.create_analytic_event_body
      analytics = JSON.parse(analytic_event_body)['analytics']

      expect(analytics.size).to eq(3)
      expect(analytics.find_all { |a| a['primary_target']['detail'] == '1' && a['actor']['detail'] == 'fastlane' }.size).to eq(1)
      expect(analytics.find_all { |a| a['event_source']['product'] != 'fastlane_web_onboarding' && a['secondary_target']['detail'] == Fastlane::VERSION && a['actor']['detail'] == 'fastlane' }.size).to eq(2)
      expect(analytics.find_all { |a| a['action']['name'] == 'fastfile_executed' && a['primary_target']['detail'] == 'crash' && a['actor']['detail'] == 'fastfile_id' }.size).to eq(1)
    end
  end

  it "posts the web onboarding data with an error when finished" do
    with_env_values('GENERATED_FASTFILE_ID' => 'fastfile_id') do
      collector.did_launch_action(:fastlane)
      collector.did_raise_error(:gym)

      analytic_event_body = collector.create_analytic_event_body
      analytics = JSON.parse(analytic_event_body)['analytics']

      expect(analytics.size).to eq(3)
      expect(analytics.find_all { |a| a['primary_target']['detail'] == '1' && a['actor']['detail'] == 'fastlane' }.size).to eq(1)
      expect(analytics.find_all { |a| a['event_source']['product'] != 'fastlane_web_onboarding' && a['secondary_target']['detail'] == Fastlane::VERSION && a['actor']['detail'] == 'fastlane' }.size).to eq(2)
      expect(analytics.find_all { |a| a['action']['name'] == 'fastfile_executed' && a['primary_target']['detail'] == 'error' && a['actor']['detail'] == 'fastfile_id' }.size).to eq(1)
    end
  end
end
