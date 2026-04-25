require 'fastlane_core/analytics/analytics_ingester_client'

describe FastlaneCore::AnalyticsIngesterClient do
  let(:measurement_id) { 'G-TEST123' }
  let(:api_secret) { 'test_api_secret' }
  let(:event) do
    {
      client_id: 'some_client_id',
      events: [
        {
          name: 'launch',
          params: {
            action_name: 'gym',
            session_id: 'some-session-uuid',
            fastlane_client_language: 'ruby',
            fastlane_version: Fastlane::VERSION,
            ruby_version: RUBY_VERSION,
            build_tool_version: 'Xcode 15.0'
          }
        }
      ]
    }
  end

  subject { described_class.new(measurement_id, api_secret) }

  describe '#post_request' do
    it 'sends a JSON POST request to the GA4 /mp/collect endpoint' do
      stub_request(:post, "https://www.google-analytics.com/mp/collect?measurement_id=#{measurement_id}&api_secret=#{api_secret}")
        .with(
          headers: {
            'Content-Type' => 'application/json',
            'User-Agent' => "fastlane/#{Fastlane::VERSION}"
          }
        )
        .to_return(status: 204, body: '', headers: {})

      response = subject.post_request(event)

      expect(response.status).to eq(204)
    end

    it 'sends a JSON body with the GA4 event payload' do
      stub_request(:post, "https://www.google-analytics.com/mp/collect?measurement_id=#{measurement_id}&api_secret=#{api_secret}")
        .with(
          body: event.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 204, body: '', headers: {})

      subject.post_request(event)
    end

    it 'includes measurement_id and api_secret as query parameters' do
      stub_request(:post, "https://www.google-analytics.com/mp/collect?measurement_id=#{measurement_id}&api_secret=#{api_secret}")
        .to_return(status: 204, body: '', headers: {})

      subject.post_request(event)

      expect(WebMock).to have_requested(:post,
        "https://www.google-analytics.com/mp/collect?measurement_id=#{measurement_id}&api_secret=#{api_secret}")
    end

    it 'does not send legacy UA url-encoded format' do
      stub_request(:post, /google-analytics\.com/)
        .to_return(status: 204, body: '', headers: {})

      subject.post_request(event)

      expect(WebMock).not_to have_requested(:post, "https://www.google-analytics.com/collect")
    end
  end

  describe '#post_event' do
    before do
      ENV.delete("FASTLANE_OPT_OUT_USAGE")
    end

    after do
      ENV.delete("FASTLANE_OPT_OUT_USAGE")
    end

    it 'returns nil when in test mode' do
      allow(FastlaneCore::Helper).to receive(:test?).and_return(true)
      result = subject.post_event(event)
      expect(result).to be_nil
    end

    it 'returns nil when user has opted out' do
      allow(FastlaneCore::Helper).to receive(:test?).and_return(false)
      ENV["FASTLANE_OPT_OUT_USAGE"] = "true"
      result = subject.post_event(event)
      expect(result).to be_nil
    end
  end

  describe '#send_request' do
    it 'retries on failure' do
      call_count = 0
      allow(subject).to receive(:post_request) do
        call_count += 1
        raise "network error" if call_count < 3
      end

      subject.send_request(event)

      expect(call_count).to eq(3)
    end
  end
end
