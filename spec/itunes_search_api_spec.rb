WebMock.disable_net_connect!(allow: 'codeclimate.com')

# iTunes Lookup API
RSpec.configure do |config|
  config.before(:each) do
    # iTunes Lookup API by Apple ID
    ["invalid", "", 0, '284882215'].each do |current|
      stub_request(:get, "https://itunes.apple.com/lookup?id=#{current}").
           with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
           to_return(status: 200, body: File.read("spec/responses/itunesLookup-#{current}.json"), headers: {})
    end

    # iTunes Lookup API by App Identifier
    stub_request(:get, "https://itunes.apple.com/lookup?bundleId=com.facebook.Facebook").
         with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
         to_return(status: 200, body: File.read("spec/responses/itunesLookup-com.facebook.Facebook.json"), headers: {})

    stub_request(:get, "https://itunes.apple.com/lookup?bundleId=net.sunapps.invalid").
         with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
         to_return(status: 200, body: File.read("spec/responses/itunesLookup-net.sunapps.invalid.json"), headers: {})
  end
end

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
      expect(response['trackId']).to eq(284882215)
    end
  end
end
