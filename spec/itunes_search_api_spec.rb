describe IosDeployKit do
  describe IosDeployKit::ItunesSearchApi do
    it "returns nil when it could not be found" do
      IosDeployKit::ItunesSearchApi.fetch("invalid").should eq(nil)
      IosDeployKit::ItunesSearchApi.fetch("").should eq(nil)
      IosDeployKit::ItunesSearchApi.fetch(0).should eq(nil)
    end

    it "returns the actual object if it could be found" do
      response = IosDeployKit::ItunesSearchApi.fetch("284882215")
      response['kind'].should eq('software')
      response['supportedDevices'].count.should be > 8

      IosDeployKit::ItunesSearchApi.fetch_bundle_identifier("284882215").should eq('com.facebook.Facebook')
    end
  end
end