require 'fastlane_core/analytics/analytics_session'

describe FastlaneCore::AnalyticsSession do
  let(:ingester_client) { double("ingester_client") }
  let(:session) { FastlaneCore::AnalyticsSession.new(analytics_ingester_client: ingester_client) }

  before do
    allow(session).to receive(:should_show_message?).and_return(false)
  end

  describe "#session_id" do
    it "is numeric, as required by GA4" do
      expect(session.session_id).to match(/^\d+$/)
    end
  end

  describe "#action_launched" do
    let(:launch_context) do
      FastlaneCore::ActionLaunchContext.new(
        action_name: 'gym',
        p_hash: 'some_hash',
        platform: :android,
        fastlane_client_language: :ruby
      )
    end

    it "posts a launch event with the environment params" do
      expect(ingester_client).to receive(:post_event) do |event|
        expect(event[:client_id]).to eq('some_hash')
        expect(event[:session_id]).to eq(session.session_id)
        expect(event[:name]).to eq(:launch)
        expect(event[:params][:fastlane_client_language]).to eq(:ruby)
        expect(event[:params][:build_tool_version]).to eq('android')
        expect(event[:params][:ruby_version]).to eq(RUBY_VERSION)
        expect(event[:params][:fastlane_version]).to eq(Fastlane::VERSION)
        nil
      end

      session.action_launched(launch_context: launch_context)
    end

    it "only sends the launch event once per session" do
      expect(ingester_client).to receive(:post_event).once.and_return(nil)

      session.action_launched(launch_context: launch_context)
      session.action_launched(launch_context: launch_context)
    end

    it "does not send an event when p_hash is nil" do
      launch_context.p_hash = nil
      expect(ingester_client).not_to receive(:post_event)

      session.action_launched(launch_context: launch_context)
    end
  end
end
