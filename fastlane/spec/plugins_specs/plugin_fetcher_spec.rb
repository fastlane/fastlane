describe Fastlane do
  describe Fastlane::PluginFetcher do
    describe "#fetch_gems" do
      before do
        # We have to stub both a specific search, and the general listing
        ["yolo", ""].each do |current_gem|
          stub_request(:get, "https://rubygems.org/api/v1/search.json?query=fastlane-plugin-#{current_gem}").
            with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' }).
            to_return(status: 200, body: File.read("spec/fixtures/requests/rubygems_plugin_query.json"), headers: {})
        end
      end

      it "returns all available plugins if no search query is given" do
        plugins = Fastlane::PluginFetcher.fetch_gems
        expect(plugins.count).to eq(2)
        plugin1 = plugins.first
        expect(plugin1.full_name).to eq("fastlane-plugin-apprepo")
        expect(plugin1.name).to eq("apprepo")
        expect(plugin1.homepage).to eq("https://github.com/suculent/fastlane-plugin-apprepo")
        expect(plugin1.downloads).to eq(113)
        expect(plugin1.info).to eq("experimental fastlane plugin")
      end

      it "returns a filtered set of plugins when a search query is passed" do
        plugins = Fastlane::PluginFetcher.fetch_gems(search_query: "yolo")
        expect(plugins.count).to eq(1)
        expect(plugins.last.name).to eq("yolokit")
      end
    end
  end
end
