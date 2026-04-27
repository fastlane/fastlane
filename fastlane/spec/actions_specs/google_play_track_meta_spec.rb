describe Fastlane do
  describe Fastlane::Actions::GooglePlayTrackMetaAction do
    let(:reader) { instance_double(Supply::Reader) }
    let(:track) { AndroidPublisher::Track.new(track: "beta", releases: []) }
    let(:json_key_path) { File.expand_path("./fastlane/spec/fixtures/google_play/google_play.json") }

    it "configures Supply and returns track metadata from the reader" do
      expect(Supply::Reader).to receive(:new).and_return(reader)
      expect(reader).to receive(:track_meta).and_return(track)

      result = described_class.run(
        package_name: "com.example.app",
        track: "beta",
        json_key: json_key_path
      )

      expect(result).to be(track)
      expect(Supply.config[:package_name]).to eq("com.example.app")
      expect(Supply.config[:track]).to eq("beta")
      expect(Supply.config[:json_key]).to eq(json_key_path)
    end
  end
end
