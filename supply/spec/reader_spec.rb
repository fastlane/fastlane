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
  end
end
