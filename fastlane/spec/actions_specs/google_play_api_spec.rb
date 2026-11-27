describe Fastlane do
  describe Fastlane::FastFile do
    describe "google_play_api" do
      let(:api) { "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.example" }
      let(:json) { { 'Content-Type' => 'application/json' } }
      let(:key) { File.expand_path("supply/spec/fixtures/sample-service-account.json") }

      before do
        stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
          .to_return(status: 200, body: '{"access_token":"a-token","expires_in":3600}', headers: json)
      end

      it "returns the parsed response" do
        stub_request(:get, "#{api}/edits/1/tracks")
          .with(headers: { 'Authorization' => 'Bearer a-token' })
          .to_return(status: 200, body: '{"tracks":[{"track":"internal"}]}', headers: json)

        result = Fastlane::FastFile.new.parse("lane :test do
          google_play_api(path: '/androidpublisher/v3/applications/com.example/edits/1/tracks', json_key: '#{key}')
        end").runner.execute(:test)

        expect(result).to eq({ status: 200, body: '{"tracks":[{"track":"internal"}]}', json: { 'tracks' => [{ 'track' => 'internal' }] } })
      end

      it "sends a Hash body as JSON" do
        stub = stub_request(:put, "#{api}/edits/1/tracks/beta")
               .with(body: '{"track":"beta","releases":[]}', headers: { 'Content-Type' => 'application/json' })
               .to_return(status: 200, body: '{"track":"beta"}', headers: json)

        Fastlane::FastFile.new.parse("lane :test do
          google_play_api(http_method: 'PUT', path: '/androidpublisher/v3/applications/com.example/edits/1/tracks/beta',
                          body: { track: 'beta', releases: [] }, json_key: '#{key}')
        end").runner.execute(:test)

        expect(stub).to have_been_requested
      end

      it "fails the lane with Google's error" do
        stub_request(:get, "#{api}/edits/9").to_return(status: 404, body: '{"error":{"code":404,"message":"No edit with id 9."}}', headers: json)

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            google_play_api(path: '/androidpublisher/v3/applications/com.example/edits/9', json_key: '#{key}')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /No edit with id 9/)
      end

      it "passes an error status to its error handler instead of failing" do
        stub_request(:get, "#{api}/edits/9").to_return(status: 404, body: '{"error":{"code":404,"message":"No edit with id 9."}}', headers: json)
        handled = nil
        Fastlane::Actions::GooglePlayApiAction.run(
          FastlaneCore::Configuration.create(Fastlane::Actions::GooglePlayApiAction.available_options,
                                             path: '/androidpublisher/v3/applications/com.example/edits/9', json_key: key,
                                             error_handlers: { 404 => proc { |result| handled = result } })
        )

        expect(handled[:status]).to eq(404)
        expect(handled[:json]['error']['message']).to eq('No edit with id 9.')
      end

      it "returns an empty body as an empty string and json" do
        stub_request(:delete, "#{api}/edits/9").to_return(status: 204, body: '')

        result = Fastlane::FastFile.new.parse("lane :test do
          google_play_api(http_method: 'DELETE', path: '/androidpublisher/v3/applications/com.example/edits/9', json_key: '#{key}')
        end").runner.execute(:test)

        expect(result).to eq({ status: 204, body: '', json: {} })
      end
    end
  end
end
