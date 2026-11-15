describe Fastlane do
  describe Fastlane::FastFile do
    describe "app_store_connect_api" do
      let(:token) { double('token', text: 'a-token', in_house: nil, expired?: false) }
      let(:api) { "https://api.appstoreconnect.apple.com/v1" }
      let(:json) { { 'Content-Type' => 'application/json' } }

      after do
        Fastlane::Actions.lane_context.delete(Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY)
      end

      it "returns the parsed response, using the key set by app_store_connect_api_key" do
        key = { key_id: "D383SF739", issuer_id: "issuer", key: "-----BEGIN PRIVATE KEY-----" }
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY] = key
        expect(Spaceship::ConnectAPI::Token).to receive(:from).with(hash: key, filepath: nil).and_return(token)
        stub_request(:get, "#{api}/apps?limit=1")
          .with(headers: { 'Authorization' => 'Bearer a-token' })
          .to_return(status: 200, body: { data: [{ type: 'apps', id: '1' }] }.to_json, headers: json)

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_connect_api(path: '/v1/apps?limit=1')
        end").runner.execute(:test)

        expect(result[:status]).to eq(200)
        expect(result[:json]).to eq({ 'data' => [{ 'type' => 'apps', 'id' => '1' }] })
        expect(JSON.parse(result[:body])).to eq(result[:json])
      end

      it "sends a Hash body as JSON" do
        allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(token)
        stub = stub_request(:patch, "#{api}/betaGroups/123")
               .with(body: { data: { type: 'betaGroups', id: '123', attributes: { name: 'QA' } } }.to_json)
               .to_return(status: 200, body: { data: { type: 'betaGroups', id: '123' } }.to_json, headers: json)

        Fastlane::FastFile.new.parse("lane :test do
          app_store_connect_api(http_method: 'PATCH', path: '/v1/betaGroups/123',
                                body: { data: { type: 'betaGroups', id: '123', attributes: { name: 'QA' } } })
        end").runner.execute(:test)

        expect(stub).to have_been_requested
      end

      it "fails the lane with Apple's error" do
        allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(token)
        stub_request(:get, "#{api}/apps/9").to_return(status: 404, body: { errors: [{ status: '404', code: 'NOT_FOUND', title: 'The specified resource does not exist', detail: "There is no resource of type 'apps' with id '9'" }] }.to_json, headers: json)

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            app_store_connect_api(path: '/v1/apps/9')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /There is no resource of type 'apps' with id '9'/)
      end

      it "passes an error status to its error handler instead of failing" do
        allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(token)
        stub_request(:get, "#{api}/betaGroups/9").to_return(status: 404, body: { errors: [{ status: '404', code: 'NOT_FOUND', title: 'Not found' }] }.to_json, headers: json)
        handled = nil
        Fastlane::Actions::AppStoreConnectApiAction.run(
          FastlaneCore::Configuration.create(Fastlane::Actions::AppStoreConnectApiAction.available_options,
                                             path: '/v1/betaGroups/9', error_handlers: { 404 => proc { |result| handled = result } })
        )

        expect(handled[:status]).to eq(404)
        expect(handled[:json]['errors'].first['code']).to eq('NOT_FOUND')
      end

      it "returns an empty body as an empty string and json" do
        allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(token)
        stub_request(:delete, "#{api}/betaGroups/9").to_return(status: 204, body: '')

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_connect_api(http_method: 'DELETE', path: '/v1/betaGroups/9')
        end").runner.execute(:test)

        expect(result).to eq({ status: 204, body: '', json: {} })
      end

      it "rejects an unknown http_method" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            app_store_connect_api(http_method: 'PUT', path: '/v1/apps')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /Unsupported http_method 'PUT'/)
      end
    end
  end
end
