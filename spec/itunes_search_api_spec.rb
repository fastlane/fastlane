describe Deliver do
  describe Deliver::ItunesSearchApi do
    it "returns nil when it could not be found" do
      expect(Deliver::ItunesSearchApi.fetch("invalid")).to eq(nil)
      expect(Deliver::ItunesSearchApi.fetch("")).to eq(nil)
      expect(Deliver::ItunesSearchApi.fetch(0)).to eq(nil)
    end

    it "returns the actual object if it could be found" do
      response = Deliver::ItunesSearchApi.fetch("284882215")
      expect(response['kind']).to eq('software')
      expect(response['supportedDevices'].count).to be > 8

      expect(Deliver::ItunesSearchApi.fetch_bundle_identifier("284882215")).to eq('com.facebook.Facebook')
    end

    it "returns the actual object if it could be found" do
      response = Deliver::ItunesSearchApi.fetch_by_identifier("com.facebook.Facebook")
      expect(response['kind']).to eq('software')
      expect(response['supportedDevices'].count).to be > 8
      expect(response['trackId']).to eq(284882215)
    end
  end
end