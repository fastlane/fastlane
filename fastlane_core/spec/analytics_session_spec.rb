require 'fastlane_core/analytics/analytics_session'

describe FastlaneCore::AnalyticsSession do
  let(:mock_client) { instance_double(FastlaneCore::AnalyticsIngesterClient) }

  subject { described_class.new(analytics_ingester_client: mock_client) }

  describe '#initialize' do
    it 'generates a unique session_id' do
      expect(subject.session_id).not_to be_nil
      expect(subject.session_id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'sets the provided client' do
      expect(subject.client).to eq(mock_client)
    end
  end

  describe '#action_launched' do
    let(:launch_context) do
      instance_double(
        FastlaneCore::ActionLaunchContext,
        p_hash: 'test_p_hash',
        fastlane_client_language: :ruby,
        build_tool_version: 'Xcode 15.0'
      )
    end

    before do
      allow(subject).to receive(:should_show_message?).and_return(false)
    end

    it 'posts a GA4 launch event' do
      allow(mock_client).to receive(:post_event).and_return(nil)

      subject.action_launched(launch_context: launch_context)

      expect(mock_client).to have_received(:post_event) do |event|
        expect(event[:client_id]).to eq('test_p_hash')
        expect(event[:events]).to be_an(Array)
        expect(event[:events][0][:name]).to eq('launch')
        expect(event[:events][0][:params][:ruby_version]).to eq(RUBY_VERSION)
        expect(event[:events][0][:params][:build_tool_version]).to eq('Xcode 15.0')
        expect(event[:events][0][:params][:fastlane_version]).to eq(Fastlane::VERSION)
        expect(event[:events][0][:params][:fastlane_client_language]).to eq('ruby')
      end
    end

    it 'does not send duplicate launch events' do
      allow(mock_client).to receive(:post_event).and_return(nil)

      subject.action_launched(launch_context: launch_context)
      subject.action_launched(launch_context: launch_context)

      expect(mock_client).to have_received(:post_event).once
    end

    it 'does not post event when p_hash is nil' do
      nil_context = instance_double(
        FastlaneCore::ActionLaunchContext,
        p_hash: nil,
        fastlane_client_language: :ruby,
        build_tool_version: 'Xcode 15.0'
      )

      allow(mock_client).to receive(:post_event)

      subject.action_launched(launch_context: nil_context)

      expect(mock_client).not_to have_received(:post_event)
    end
  end

  describe '#finalize_session' do
    it 'joins all threads' do
      thread = instance_double(Thread)
      allow(thread).to receive(:join)

      allow(mock_client).to receive(:post_event).and_return(thread)
      allow(subject).to receive(:should_show_message?).and_return(false)

      launch_context = instance_double(
        FastlaneCore::ActionLaunchContext,
        p_hash: 'test_p_hash',
        fastlane_client_language: :ruby,
        build_tool_version: 'Xcode 15.0'
      )

      subject.action_launched(launch_context: launch_context)
      subject.finalize_session

      expect(thread).to have_received(:join)
    end
  end
end
