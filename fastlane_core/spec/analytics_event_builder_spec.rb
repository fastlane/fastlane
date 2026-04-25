require 'fastlane_core/analytics/analytics_event_builder'

describe FastlaneCore::AnalyticsEventBuilder do
  let(:p_hash) { 'some_p_hash_value' }
  let(:session_id) { 'some-session-uuid' }
  let(:action_name) { 'gym' }
  let(:fastlane_client_language) { :ruby }
  let(:build_tool_version) { 'Xcode 15.0' }

  subject do
    described_class.new(
      p_hash: p_hash,
      session_id: session_id,
      action_name: action_name,
      fastlane_client_language: fastlane_client_language,
      build_tool_version: build_tool_version
    )
  end

  describe '#new_event' do
    it 'returns a GA4-compatible event structure' do
      event = subject.new_event(:launch)

      expect(event[:client_id]).to eq(p_hash)
      expect(event[:events]).to be_an(Array)
      expect(event[:events].length).to eq(1)
    end

    it 'uses the action_stage as the event name' do
      event = subject.new_event(:launch)

      expect(event[:events][0][:name]).to eq('launch')
    end

    it 'includes action_name in event params' do
      event = subject.new_event(:launch)
      params = event[:events][0][:params]

      expect(params[:action_name]).to eq(action_name)
    end

    it 'includes session_id in event params' do
      event = subject.new_event(:launch)
      params = event[:events][0][:params]

      expect(params[:session_id]).to eq(session_id)
    end

    it 'includes fastlane_client_language in event params' do
      event = subject.new_event(:launch)
      params = event[:events][0][:params]

      expect(params[:fastlane_client_language]).to eq('ruby')
    end

    it 'includes fastlane_version in event params' do
      event = subject.new_event(:launch)
      params = event[:events][0][:params]

      expect(params[:fastlane_version]).to eq(Fastlane::VERSION)
    end

    it 'includes ruby_version in event params' do
      event = subject.new_event(:launch)
      params = event[:events][0][:params]

      expect(params[:ruby_version]).to eq(RUBY_VERSION)
    end

    it 'includes build_tool_version in event params' do
      event = subject.new_event(:launch)
      params = event[:events][0][:params]

      expect(params[:build_tool_version]).to eq(build_tool_version)
    end

    it 'defaults action_name to "unknown" when nil' do
      builder = described_class.new(
        p_hash: p_hash,
        session_id: session_id,
        action_name: nil,
        fastlane_client_language: fastlane_client_language,
        build_tool_version: build_tool_version
      )

      event = builder.new_event(:launch)
      params = event[:events][0][:params]

      expect(params[:action_name]).to eq('unknown')
    end

    it 'defaults build_tool_version to "unknown" when nil' do
      builder = described_class.new(
        p_hash: p_hash,
        session_id: session_id,
        action_name: action_name,
        fastlane_client_language: fastlane_client_language,
        build_tool_version: nil
      )

      event = builder.new_event(:launch)
      params = event[:events][0][:params]

      expect(params[:build_tool_version]).to eq('unknown')
    end

    it 'does not include legacy UA fields' do
      event = subject.new_event(:launch)

      expect(event).not_to have_key(:category)
      expect(event).not_to have_key(:action)
      expect(event).not_to have_key(:label)
      expect(event).not_to have_key(:value)
    end
  end
end
