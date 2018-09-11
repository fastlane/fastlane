describe FastlaneCore::AnalyticsSession do
  let(:fastlane_client_language) { :ruby }
  let(:p_hash) { 'some.phash.value' }
  let(:session_id) { 's0m3s3ss10n1D' }

  before(:each) do
    # This value needs to be set or our event fixtures will not match
    allow(FastlaneCore::Helper).to receive(:ci?).and_return(false)
    allow(FastlaneCore::Helper).to receive(:operating_system).and_return('macOS')
  end

  context 'single action execution' do
    let(:action_name) { 'some_action' }

    context 'action launch' do
      let(:launch_context) do
        FastlaneCore::ActionLaunchContext.new(
          action_name: action_name,
          p_hash: p_hash,
          platform: 'ios',
          fastlane_client_language: fastlane_client_language
        )
      end

      it 'analytics session: launch' do
        expect(SecureRandom).to receive(:uuid).and_return(session_id)

        # Stub out calls related to the execution environment
        client = double("ingester_client")
        session = FastlaneCore::AnalyticsSession.new(analytics_ingester_client: client)
        expect(client).to receive(:post_event).with({
            client_id: p_hash,
            category: 'fastlane Client Langauge - ruby',
            action: :launch,
            label: nil,
            value: nil
        })

        session.action_launched(launch_context: launch_context)
      end
    end
  end
end
