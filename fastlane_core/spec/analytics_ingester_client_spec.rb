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
        value: nil,
        custom_params: {
          ruby_version: "2.7.0",
          xcode_version: "14.0",
          platform: "ios",
          client_language: "ruby"
        }
      }

      # Stub the GA4 endpoint
      stub = stub_request(:post, "https://www.google-analytics.com/mp/collect?measurement_id=G-94HQ3VVP0X")
        .with do |request|
          body = JSON.parse(request.body)
          
          # Verify GA4 payload structure
          expect(body["client_id"]).to eq("test_client_id_123")
          expect(body["events"]).to be_an(Array)
          expect(body["events"].length).to eq(1)
          
          event_data = body["events"][0]
          expect(event_data["name"]).to eq("launch")
          expect(event_data["params"]["event_category"]).to eq("fastlane Client Language - ruby")
          expect(event_data["params"]["event_label"]).to eq("test_action")
          expect(event_data["params"]["value"]).to eq(0)
          expect(event_data["params"]["engagement_time_msec"]).to eq(100)
          
          # Verify custom params are included
          expect(event_data["params"]["ruby_version"]).to eq("2.7.0")
          expect(event_data["params"]["xcode_version"]).to eq("14.0")
          expect(event_data["params"]["platform"]).to eq("ios")
          expect(event_data["params"]["client_language"]).to eq("ruby")
          
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

      # Stub the GA4 endpoint
      stub = stub_request(:post, "https://www.google-analytics.com/mp/collect?measurement_id=G-94HQ3VVP0X")
        .with do |request|
          body = JSON.parse(request.body)
          
          expect(body["client_id"]).to eq("test_client_id_456")
          event_data = body["events"][0]
          expect(event_data["name"]).to eq("complete")
          expect(event_data["params"]["event_category"]).to eq("fastlane Client Language - swift")
          expect(event_data["params"]["event_label"]).to eq("na")
          expect(event_data["params"]["value"]).to eq(0)
          
          true
        end
        .to_return(status: 200, body: "", headers: {})

      client.post_request(event)
      
      expect(stub).to have_been_requested
    end
  end
end
