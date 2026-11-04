require 'supply'
require 'supply/reader'

describe Supply do
  describe Supply::Reader do
    describe "#track_meta" do
      let(:reader) { described_class.new }
      let(:client) { instance_double(Supply::Client) }
      let(:track) { AndroidPublisher::Track.new(track: "production", releases: []) }

      before do
        allow(reader).to receive(:client).and_return(client)
        Supply.config = { package_name: "com.example.app", track: "production" }
      end

      it "opens an edit, fetches track metadata, aborts the edit, and returns the track" do
        expect(client).to receive(:begin_edit).with(package_name: "com.example.app").ordered
        expect(client).to receive(:get_edit_track).with("production").and_return(track).ordered
        expect(client).to receive(:abort_current_edit).ordered

        expect(reader.track_meta).to be(track)
      end

      it "returns nil when the API reports an empty or missing track" do
        expect(client).to receive(:begin_edit).with(package_name: "com.example.app")
        expect(client).to receive(:get_edit_track).with("production").and_return(nil)
        expect(client).to receive(:abort_current_edit)

        expect(reader.track_meta).to be_nil
      end
    end

    describe "#track_release_summaries" do
      let(:reader) { described_class.new }
      let(:client) { instance_double(Supply::Client) }

      before do
        allow(reader).to receive(:client).and_return(client)
        Supply.config = { package_name: "com.example.app", track: "beta" }
      end

      it "fetches release summaries without opening an edit" do
        summaries = [
          AndroidPublisher::ReleaseSummary.new(release_name: "1.0.0", release_lifecycle_state: "inProgress", track: "beta"),
          AndroidPublisher::ReleaseSummary.new(release_name: "2.0.0", release_lifecycle_state: "halted", track: "beta")
        ]

        expect(client).to receive(:list_track_release_summaries).with("com.example.app", "beta").and_return(summaries)
        expect(client).not_to receive(:begin_edit)
        expect(client).not_to receive(:abort_current_edit)

        result = reader.track_release_summaries
        expect(result).to be(summaries)
        expect(result.length).to be(2)
      end

      it "returns an empty array when no releases exist" do
        expect(client).to receive(:list_track_release_summaries).with("com.example.app", "beta").and_return([])

        expect(reader.track_release_summaries).to eq([])
      end
    end
  end
end
