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
          expect("#{e}").to eq("Failed to fetch Bots from Xcode Server at https://1.2.3.4, response: 500: .".red)
        else
          fail "Error should have been raised"
        end
      end

      it "fails if selected bot doesn't have any integrations" do
        stub_request(:get, "https://1.2.3.4:20343/api/bots").
        to_return(status: 200, body: File.read("./spec/fixtures/requests/xcode_server_bots.json"))
        stub_request(:get, "https://1.2.3.4:20343/api/bots/c7ccb2e699d02c74cf750a189360426d/integrations?limit=10").
        to_return(status: 200, body: "{\"count\":0,\"results\":[]}")

        begin
          result = Fastlane::FastFile.new.parse("lane :test do
            xcode_server_get_assets(
                host: '1.2.3.4',
                bot_name: 'bot-2'
              )
          end").runner.execute(:test)
        rescue => e
          expect("#{e}").to eq("Failed to find any completed integration for Bot \"bot-2\"".red)
        else
          fail "Error should have been raised"
        end
      end

      it "fails if integration number specified is not available" do
        stub_request(:get, "https://1.2.3.4:20343/api/bots").
        to_return(status: 200, body: File.read("./spec/fixtures/requests/xcode_server_bots.json"))
        stub_request(:get, "https://1.2.3.4:20343/api/bots/c7ccb2e699d02c74cf750a189360426d/integrations?limit=10").
        to_return(status: 200, body: File.read("./spec/fixtures/requests/xcode_server_integrations.json"))

        begin
          result = Fastlane::FastFile.new.parse("lane :test do
            xcode_server_get_assets(
                host: '1.2.3.4',
                bot_name: 'bot-2',
                integration_number: 3
              )
          end").runner.execute(:test)
        rescue => e
          expect("#{e}").to eq("Specified integration number 3 does not exist.".red)
        else
          fail "Error should have been raised"
        end
      end

      it "fails if assets are not available" do
        stub_request(:get, "https://1.2.3.4:20343/api/bots").
        to_return(status: 200, body: File.read("./spec/fixtures/requests/xcode_server_bots.json"))
        stub_request(:get, "https://1.2.3.4:20343/api/bots/c7ccb2e699d02c74cf750a189360426d/integrations?limit=10").
        to_return(status: 200, body: File.read("./spec/fixtures/requests/xcode_server_integrations.json"))
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
          expect("#{e}").to eq("Integration doesn't have any assets (it probably never ran).".red)
        else
          fail "Error should have been raised"
        end
      end

      # it "downloads and unzips the assets that don't contain an xcarchive" do
      #   stub_request(:get, "https://1.2.3.4:20343/api/bots").
      #   to_return(:status => 200, :body => File.read("./spec/fixtures/requests/xcode_server_bots.json"))
      #   stub_request(:get, "https://1.2.3.4:20343/api/bots/c7ccb2e699d02c74cf750a189360426d/integrations?limit=10").
      #   to_return(:status => 200, :body => File.read("./spec/fixtures/requests/xcode_server_integrations.json"))
      #   stub_request(:get, "https://1.2.3.4:20343/api/integrations/0a0fb158e7bf3d06aa87bf96eb001454/assets").
      #   to_return(:status => 200, :body => File.read("./spec/fixtures/requests/xcs.tar.gz"), :headers => {
      #       "Content-type" => "application/gzip",
      #       "Content-Disposition"=>"attachment; filename=\"xcs.tar.gz\"",
      #       "Accept-Ranges"=>"bytes",
      #       "Content-Length"=>"160"
      #     })

      #   # fails but shouldn't, can't internally unzip the .tar.gz only in tests, even though when I copy the same command to the command line it works :/
      #   result = Fastlane::FastFile.new.parse("lane :test do
      #     xcode_server_get_assets(
      #         host: '1.2.3.4',
      #         bot_name: 'bot-2'
      #       )
      #   end").runner.execute(:test)
      # end

      # TODO
      # it "downloads assets that contain an xcarchive and deletes everything else" do
      # end

      # it "downloads assets that contain an xcarchive and keeps everything else" do
      # end
    end
  end
end
