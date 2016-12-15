describe FastlaneCore do
  describe FastlaneCore::ItunesSearchApi do
    it "returns nil when it could not be found" do
      expect(FastlaneCore::ItunesSearchApi.fetch("invalid")).to eq(nil)
      expect(FastlaneCore::ItunesSearchApi.fetch("")).to eq(nil)
      expect(FastlaneCore::ItunesSearchApi.fetch(0)).to eq(nil)
    end

    it "returns the actual object if it could be found" do
      response = FastlaneCore::ItunesSearchApi.fetch("284882215")
      expect(response['kind']).to eq('software')
      expect(response['supportedDevices'].count).to be > 8

      expect(FastlaneCore::ItunesSearchApi.fetch_bundle_identifier("284882215")).to eq('com.facebook.Facebook')
    end

    it "returns the actual object if it could be found" do
      response = FastlaneCore::ItunesSearchApi.fetch_by_identifier("com.facebook.Facebook")
      expect(response['kind']).to eq('software')
      expect(response['supportedDevices'].count).to be > 8
      expect(response['trackId']).to eq(284_882_215)
    end

    it "can find country specific object" do
      response = FastlaneCore::ItunesSearchApi.fetch(338_986_109, 'FR')
      expect(response['kind']).to eq('software')
      expect(response['supportedDevices'].count).to be > 8
      expect(response['trackId']).to eq(338_986_109)
    end
  end
end
