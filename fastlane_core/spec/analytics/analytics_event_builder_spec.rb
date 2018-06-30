describe FastlaneCore::AnalyticsEventBuilder do
  let(:p_hash) { 'some.phash.value' }
  let(:session_id) { 's0m3s3ss10n1D' }
  let(:action_name) { 'some_action' }

  let(:builder) do
    FastlaneCore::AnalyticsEventBuilder.new(
      p_hash: p_hash,
      session_id: session_id,
      action_name: action_name
    )
  end

  context '#launch_event' do
    it 'creates a launch event' do
      event = builder.new_event(:launch)
      expect(event).to eq(
        {
          client_id: p_hash,
          category: :undefined,
          action: :launch,
          label: action_name,
          value: nil
        }
      )
    end
  end
end
