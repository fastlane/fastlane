require 'fastlane_core/analytics/analytics_ingester_client'
require 'fastlane_core/analytics/analytics_event_builder'
require 'webmock/rspec'

describe FastlaneCore::AnalyticsIngesterClient do
  before do
    stub_const('Fastlane::VERSION', '2.0.0')
  end

  describe "#post_request" do
    it "sends GA4 formatted payload to the correct endpoint" do
      client = FastlaneCore::AnalyticsIngesterClient.new("G-94HQ3VVP0X")

      event = {
        client_id: "test_client_id_123",
        category: "fastlane Client Language - ruby",
        action: :launch,
        label: "test_action",
        value: 42,
        custom_params: {
          ruby_version: "2.7.0",
          xcode_version: "14.0",
          platform: "ios",
          client_language: "ruby"
        }
      }

      # Stub the GA4 client-side endpoint
      stub = stub_request(:post, "https://www.google-analytics.com/g/collect")
             .with do |request|
        # Parse URL-encoded body
        params = URI.decode_www_form(request.body).to_h

        # Verify GA4 client-side payload structure
        expect(params["v"]).to eq("2")
        expect(params["tid"]).to eq("G-94HQ3VVP0X")
        expect(params["cid"]).to eq("test_client_id_123")
        expect(params["en"]).to eq("launch")
        expect(params["_dbg"]).to eq("1")

        # Verify standard event parameters
        expect(params["ep.event_category"]).to eq("fastlane Client Language - ruby")
        expect(params["ep.event_label"]).to eq("test_action")
        expect(params["ep.value"]).to eq("42")

        # Verify custom params are included with ep. prefix
        expect(params["ep.ruby_version"]).to eq("2.7.0")
        expect(params["ep.xcode_version"]).to eq("14.0")
        expect(params["ep.platform"]).to eq("ios")
        expect(params["ep.client_language"]).to eq("ruby")

        true
      end
             .to_return(status: 200, body: "", headers: {})

      client.post_request(event)

      expect(stub).to have_been_requested
    end

    it "handles events without custom params" do
      client = FastlaneCore::AnalyticsIngesterClient.new("G-94HQ3VVP0X")

      event = {
        client_id: "test_client_id_456",
        category: "fastlane Client Language - swift",
        action: :complete,
        label: nil,
        value: nil
      }

      # Stub the GA4 client-side endpoint
      stub = stub_request(:post, "https://www.google-analytics.com/g/collect")
             .with do |request|
        params = URI.decode_www_form(request.body).to_h

        expect(params["v"]).to eq("2")
        expect(params["tid"]).to eq("G-94HQ3VVP0X")
        expect(params["cid"]).to eq("test_client_id_456")
        expect(params["en"]).to eq("complete")
        expect(params["ep.event_category"]).to eq("fastlane Client Language - swift")
        expect(params["ep.event_label"]).to eq("na")
        expect(params["ep.value"]).to eq("0")

        true
      end
             .to_return(status: 200, body: "", headers: {})

      client.post_request(event)

      expect(stub).to have_been_requested
    end
  end
end
