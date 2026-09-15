require 'fastlane_core/analytics/analytics_ingester_client'

describe FastlaneCore::AnalyticsIngesterClient do
  let(:client) { FastlaneCore::AnalyticsIngesterClient.new('G-XXXXXXXXXX') }

  let(:event) do
    {
      client_id: 'some_hash',
      session_id: '1750000000',
      name: :launch,
      engagement_time_msec: 45_000,
      params: {
        fastlane_client_language: :ruby,
        fastlane_version: '2.228.0',
        install_method: 'gem',
        ruby_version: '3.2.2',
        operating_system: 'macOS',
        build_tool_version: 'Xcode 16.0',
        ci: 'false'
      }
    }
  end

  describe "#post_event" do
    it "returns nil during tests and does not post" do
      expect(client.post_event(event)).to be_nil
    end

    it "returns nil when the user opted out" do
      allow(FastlaneCore::Helper).to receive(:test?).and_return(false)
      FastlaneSpec::Env.with_env_values('FASTLANE_OPT_OUT_USAGE' => '1') do
        expect(client.post_event(event)).to be_nil
      end
    end
  end

  describe "#post_request" do
    it "posts the event to the GA4 /g/collect endpoint" do
      stub = stub_request(:post, "https://www.google-analytics.com/g/collect")
             .with(query: {
               'v' => '2',
               'tid' => 'G-XXXXXXXXXX',
               'cid' => 'some_hash',
               'sid' => '1750000000',
               '_ss' => '1',
               'seg' => '1',
               '_et' => '45000',
               'en' => 'launch',
               'ep.fastlane_client_language' => 'ruby',
               'ep.fastlane_version' => '2.228.0',
               'ep.install_method' => 'gem',
               'ep.ruby_version' => '3.2.2',
               'ep.operating_system' => 'macOS',
               'ep.build_tool_version' => 'Xcode 16.0',
               'ep.ci' => 'false'
             },
                   headers: { 'User-Agent' => 'fastlane/' + Fastlane::VERSION })

      client.post_request(event)

      expect(stub).to have_been_requested
    end
  end

  describe "#send_request" do
    it "retries failed requests" do
      expect(client).to receive(:post_request).exactly(3).times.and_raise(Faraday::ConnectionFailed.new("error"))
      client.send_request(event, retries: 2)
    end
  end
end
