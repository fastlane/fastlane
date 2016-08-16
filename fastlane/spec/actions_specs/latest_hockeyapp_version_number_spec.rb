describe Fastlane do
  describe Fastlane::FastFile do
    describe "latest HockeyApp version" do
      before do
        stub_request(:get, "https://rink.hockeyapp.net/api/2/apps").
          with(headers: { 'Accept' => 'application/json', 'X-Hockeyapptoken' => 'xxx' }).
          to_return(status: 200, body: { apps: [{
                                                title: "HockeyTest",
                                                bundle_identifier: "de.codenauts.hockeytest.beta",
                                                public_identifier: "1234567890abcdef1234567890abcdef",
                                                device_family: "iPhone/iPod",
                                                minimum_os_version: "4.0",
                                                release_type: 0,
                                                status: 2,
                                                platform: "iOS"
                                               }],
                                               status: "success" }.to_json, headers: {})
        stub_request(:get, "https://rink.hockeyapp.net/api/2/apps/1234567890abcdef1234567890abcdef/app_versions").
          with(headers: { 'Accept' => 'application/json', 'X-Hockeyapptoken' => 'xxx' }).
          to_return(status: 200, body: { app_versions: [{
                                                         version: "208"
                                                        }, {
                                                         version: "195"
                                                        }],
                                                        status: "success" }.to_json, headers: {})
      end

      it "raises an error if no app name was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            latest_hockeyapp_version_number({
              api_token: 'xxx'
            })
          end").runner.execute(:test)
        end.to raise_error("No App Name for LatestHockeyappVersionNumberAction given, pass using `app_name: 'token'`")
      end

      it "returns the latest version" do
        version = Fastlane::FastFile.new.parse("lane :test do
          latest_hockeyapp_version_number({
            api_token: 'xxx',
            app_name: 'HockeyTest'
          })
        end").runner.execute(:test)

        expect(version).to eq(208)
      end
    end
  end
end
