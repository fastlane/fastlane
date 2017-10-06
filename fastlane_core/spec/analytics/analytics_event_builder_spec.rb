describe FastlaneCore::AnalyticsEventBuilder do
  let(:oauth_app_name) { 'fastlane-tests' }
  let(:p_hash) { 'some.phash.value' }
  let(:session_id) { 's0m3s3ss10n1D' }
  let(:action_name) { 'some_action' }
  let(:timestamp_millis) { 1_507_142_046_000 }

  let(:builder) do
    FastlaneCore::AnalyticsEventBuilder.new(
      oauth_app_name: oauth_app_name,
      p_hash: p_hash,
      session_id: session_id,
      action_name: action_name,
      timestamp_millis: timestamp_millis
    )
  end

  context '#launched_event' do
    it 'creates a new launched event with primary target' do
      event = builder.launched_event(
        primary_target_hash: {
          name: 'primary target name',
          detail: 'primary target detail'
        }
      )
      expect(event).to eq(
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
            name: 'launched',
            detail: action_name
          },
          primary_target: {
            name: 'primary target name',
            detail: 'primary target detail'
          },
          millis_since_epoch: timestamp_millis,
          version: 1
        }
      )
    end

    it 'creates a new launched event with primary and secondary targets' do
      event = builder.launched_event(
        primary_target_hash: {
          name: 'primary target name',
          detail: 'primary target detail'
        },
        secondary_target_hash: {
          name: 'secondary target name',
          detail: 'secondary target detail'
        }
      )
      expect(event).to eq(
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
            name: 'launched',
            detail: action_name
          },
          primary_target: {
            name: 'primary target name',
            detail: 'primary target detail'
          },
          secondary_target: {
            name: 'secondary target name',
            detail: 'secondary target detail'
          },
          millis_since_epoch: timestamp_millis,
          version: 1
        }
      )
    end
  end

  context '#completed_event' do
    it 'creates a completed_event with a primary target' do
      event = builder.completed_event(
        primary_target_hash: {
          name: 'primary target name',
          detail: 'primary target detail'
        }
      )
      expect(event).to eq(
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
            name: 'primary target name',
            detail: 'primary target detail'
          },
          millis_since_epoch: timestamp_millis,
          version: 1
        }
      )
    end
  end
end
