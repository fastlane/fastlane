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

  it "posts the collected data when finished" do
    collector.did_launch_action(:gym)
    collector.did_launch_action(:scan)
    collector.did_crash(:scan)
    url = collector.did_finish

    form = Hash[URI.decode_www_form(url.split("?")[1])]
    form["steps"] = JSON.parse form["steps"]
    form["versions"] = JSON.parse form["versions"]

    expect(form["steps"]["gym"]).to eq(1)
    expect(form["steps"]["scan"]).to eq(1)

    expect(form["versions"]["gym"]).to eq(Fastlane::VERSION)
    expect(form["versions"]["scan"]).to eq(Fastlane::VERSION)

    expect(form["error"]).to eq("scan")
    expect(form["crash"]).to eq("scan")
  end
end
