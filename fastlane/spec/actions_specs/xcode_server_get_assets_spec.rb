describe Fastlane do
  describe Fastlane::FastFile do
    describe "xcode_server_get_assets" do
      it "fails if server is unavailable" do
        stub_request(:get, "https://1.2.3.4:20343/api/bots").to_return(status: 500)

        begin
          result = Fastlane::FastFile.new.parse("lane :test do
            xcode_server_get_assets(
              host: '1.2.3.4',
              bot_name: ''
              )
            end").runner.execute(:test)
        rescue => e
          expect(e.to_s).to eq("Failed to fetch Bots from Xcode Server at https://1.2.3.4, response: 500: .")
        else
          fail("Error should have been raised")
        end
      end

      context "ssl verification" do
        # Restores the default in case a change to the action alters it again.
        around do |example|
          example.run
        ensure
          Excon.defaults[:ssl_verify_peer] = true
        end

        before { stub_request(:get, "https://1.2.3.4:20343/api/bots").to_return(status: 500) }

        def fetch_bots(trust_self_signed_certs)
          Fastlane::FastFile.new.parse("lane :test do
            xcode_server_get_assets(host: '1.2.3.4', bot_name: '', trust_self_signed_certs: #{trust_self_signed_certs})
          end").runner.execute(:test)
        end

        it "trusts a self-signed certificate for its own requests only" do
          expect(Excon).to receive(:get).with(anything, hash_including(ssl_verify_peer: false)).and_call_original

          expect { fetch_bots(true) }.to raise_error(/Failed to fetch Bots/)
          expect(Excon.defaults[:ssl_verify_peer]).to eq(true)
        end

        it "verifies the certificate when told not to trust self-signed ones" do
          expect(Excon).to receive(:get).with(anything, hash_including(ssl_verify_peer: true)).and_call_original

          expect { fetch_bots(false) }.to raise_error(/Failed to fetch Bots/)
        end
      end

      it "fails if selected bot doesn't have any integrations" do
        stub_request(:get, "https://1.2.3.4:20343/api/bots").
          to_return(status: 200, body: File.read("./fastlane/spec/fixtures/requests/xcode_server_bots.json"))
        stub_request(:get, "https://1.2.3.4:20343/api/bots/c7ccb2e699d02c74cf750a189360426d/integrations?last=10").
          to_return(status: 200, body: "{\"count\":0,\"results\":[]}")

        begin
          result = Fastlane::FastFile.new.parse("lane :test do
            xcode_server_get_assets(
                host: '1.2.3.4',
                bot_name: 'bot-2'
              )
          end").runner.execute(:test)
        rescue => e
          expect(e.to_s).to eq("Failed to find any completed integration for Bot \"bot-2\"")
        else
          fail("Error should have been raised")
        end
      end

      it "fails if integration number specified is not available" do
        stub_request(:get, "https://1.2.3.4:20343/api/bots").
          to_return(status: 200, body: File.read("./fastlane/spec/fixtures/requests/xcode_server_bots.json"))
        stub_request(:get, "https://1.2.3.4:20343/api/bots/c7ccb2e699d02c74cf750a189360426d/integrations?last=10").
          to_return(status: 200, body: File.read("./fastlane/spec/fixtures/requests/xcode_server_integrations.json"))

        begin
          result = Fastlane::FastFile.new.parse("lane :test do
            xcode_server_get_assets(
                host: '1.2.3.4',
                bot_name: 'bot-2',
                integration_number: 3
              )
          end").runner.execute(:test)
        rescue => e
          expect(e.to_s).to eq("Specified integration number 3 does not exist.")
        else
          fail("Error should have been raised")
        end
      end

      it "fails if assets are not available" do
        stub_request(:get, "https://1.2.3.4:20343/api/bots").
          to_return(status: 200, body: File.read("./fastlane/spec/fixtures/requests/xcode_server_bots.json"))
        stub_request(:get, "https://1.2.3.4:20343/api/bots/c7ccb2e699d02c74cf750a189360426d/integrations?last=10").
          to_return(status: 200, body: File.read("./fastlane/spec/fixtures/requests/xcode_server_integrations.json"))
        stub_request(:get, "https://1.2.3.4:20343/api/integrations/0a0fb158e7bf3d06aa87bf96eb001454/assets").
          to_return(status: 500)

        begin
          result = Fastlane::FastFile.new.parse("lane :test do
            xcode_server_get_assets(
                host: '1.2.3.4',
                bot_name: 'bot-2'
              )
          end").runner.execute(:test)
        rescue => e
          expect(e.to_s).to eq("Integration doesn't have any assets (it probably never ran).")
        else
          fail("Error should have been raised")
        end
      end
    end
  end
end
