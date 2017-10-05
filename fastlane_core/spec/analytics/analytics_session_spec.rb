describe FastlaneCore::AnalyticsSession do
  let(:oauth_app_name) { 'fastlane-tests' }
  let(:p_hash) { 'some.phash.value' }
  let(:session_id) { 's0m3s3ss10n1D' }
  let(:action_name) { 'some_action' }
  let(:timestamp_millis) { 1_507_142_046 }

  context 'event completion' do
    let(:completion_context) do
      context = FastlaneCore::ActionCompletionContext.new(
        status: FastlaneCore::CompletionStatus::SUCCESS,
        action_name: action_name
      )
    end

    it 'appends a completion event to the events array' do
      expect(SecureRandom).to receive(:uuid).and_return(session_id)
      expect(Time).to receive(:now).and_return(timestamp_millis)

      session = FastlaneCore::AnalyticsSession.new(p_hash: p_hash)
      expect(session).to receive(:oauth_app_name).and_return(oauth_app_name)

      session.action_completed(completion_context: completion_context)
      expect(session.events.last).to eq(
        {
          event_source: {
            oauth_app_name: oauth_app_name,
            product: 'fastlane'
          },
          actor: {
            name: p_hash,
            detail: session_id
          },
          action: {
            name: 'completed',
            detail: action_name
          },
          primary_target: {
            name: 'status',
            detail: 'success'
          },
          timestamp_millis: timestamp_millis * 1000,
          version: 1
        }
      )
    end
  end
end
