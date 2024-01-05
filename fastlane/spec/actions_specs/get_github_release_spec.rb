describe Fastlane do
  describe Fastlane::FastFile do
    describe "get_github_release" do
      before do
        stub_request(:get, "https://api.github.com/repos/fastlane/fastlane/releases").
          with(headers: { 'Host' => 'api.github.com:443' }).
          to_return(status: 200, body: File.read("./fastlane/spec/fixtures/requests/github_releases.json"), headers: {})
      end

      it "correctly fetches all the data from GitHub" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_github_release(url: 'fastlane/fastlane', version: '1.8.0')
        end").runner.execute(:test)

        expect(result['author']['login']).to eq("KrauseFx")
        expect(result['name']).to eq("1.8.0 Switch Lanes & Pass Parameters")
        expect(result['tag_name']).to eq('1.8.0')
      end

      it "returns nil if release can't be found" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_github_release(url: 'fastlane/fastlane', version: 'notExistent')
        end").runner.execute(:test)

        expect(result).to eq(nil)
      end
    end
  end
end
