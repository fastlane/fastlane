require 'fastlane_core/analytics/analytics_event_builder'

describe FastlaneCore::AnalyticsEventBuilder do
  let(:p_hash) { 'some_hash' }
  let(:session_id) { '1750000000' }

  let(:builder) do
    FastlaneCore::AnalyticsEventBuilder.new(
      p_hash: p_hash,
      session_id: session_id,
      action_name: nil,
      fastlane_client_language: :ruby,
      build_tool_version: 'Xcode 16.0'
    )
  end

  describe "#new_event" do
    before do
      allow(FastlaneCore::Helper).to receive(:bundler?).and_return(false)
      allow(FastlaneCore::Helper).to receive(:contained_fastlane?).and_return(false)
      allow(FastlaneCore::Helper).to receive(:homebrew?).and_return(false)
      allow(FastlaneCore::Helper).to receive(:mac_app?).and_return(false)
      allow(FastlaneCore::Helper).to receive(:ci?).and_return(false)
    end

    it "creates a GA4 event with client_id, session_id, name and params" do
      event = builder.new_event(:launch)

      expect(event[:client_id]).to eq(p_hash)
      expect(event[:session_id]).to eq(session_id)
      expect(event[:name]).to eq(:launch)
      expect(event[:params]).to eq({
        fastlane_client_language: :ruby,
        fastlane_version: Fastlane::VERSION,
        install_method: 'gem',
        ruby_version: RUBY_VERSION,
        operating_system: FastlaneCore::Helper.operating_system,
        build_tool_version: 'Xcode 16.0',
        ci: 'false'
      })
    end

    it "omits nil values from params" do
      builder = FastlaneCore::AnalyticsEventBuilder.new(
        p_hash: p_hash,
        session_id: session_id,
        fastlane_client_language: :ruby,
        build_tool_version: nil
      )

      event = builder.new_event(:launch)
      expect(event[:params]).not_to have_key(:build_tool_version)
    end

    it "reports the install method" do
      allow(FastlaneCore::Helper).to receive(:bundler?).and_return(true)

      event = builder.new_event(:launch)
      expect(event[:params][:install_method]).to eq('bundler')
    end
  end
end
