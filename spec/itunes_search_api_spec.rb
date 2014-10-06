describe IosDeployKit do
  describe IosDeployKit::ItunesSearchApi do
    it "returns nil when it could not be found" do
      expect(IosDeployKit::ItunesSearchApi.fetch("invalid")).to eq(nil)
      expect(IosDeployKit::ItunesSearchApi.fetch("")).to eq(nil)
      expect(IosDeployKit::ItunesSearchApi.fetch(0)).to eq(nil)
    end

    it "returns the actual object if it could be found" do
      response = IosDeployKit::ItunesSearchApi.fetch("284882215")
      expect(response['kind']).to eq('software')
      expect(response['supportedDevices'].count).to be > 8

      expect(IosDeployKit::ItunesSearchApi.fetch_bundle_identifier("284882215")).to eq('com.facebook.Facebook')
    end

    it "returns the actual object if it could be found" do
      response = IosDeployKit::ItunesSearchApi.fetch_by_identifier("com.facebook.Facebook")
      expect(response['kind']).to eq('software')
      expect(response['supportedDevices'].count).to be > 8
      expect(response['trackId']).to eq(284882215)
    end
  end
end