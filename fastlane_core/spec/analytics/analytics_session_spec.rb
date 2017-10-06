describe FastlaneCore::AnalyticsSession do
  let(:oauth_app_name) { 'fastlane-tests' }
  let(:p_hash) { 'some.phash.value' }
  let(:session_id) { 's0m3s3ss10n1D' }
  let(:action_name) { 'some_action' }
  let(:timestamp_millis) { 1_507_142_046 }

  context 'action launch' do
    let(:launch_context) do
      FastlaneCore::ActionLaunchContext.new(
        action_name: action_name,
        p_hash: p_hash,
        platform: 'ios'
      )
    end

    let(:fixture_data) do
      dirname = File.expand_path(File.dirname(__FILE__))
      JSON.parse(File.read(File.join(dirname, './fixtures/launched.json')))
    end

    it "adds all events to the session's events array" do
      expect(SecureRandom).to receive(:uuid).and_return(session_id)
      allow(Time).to receive(:now).and_return(timestamp_millis)

      session = FastlaneCore::AnalyticsSession.new
      session.is_fastfile = true
      allow(session).to receive(:oauth_app_name).and_return(oauth_app_name)
      session.action_launched(launch_context: launch_context)

      fixture_data.each do |event|
        event['millis_since_epoch'] = timestamp_millis * 1000
        if event['primary_target']['name'] == 'fastlane_version'
          event['primary_target']['detail'] = session.fastlane_version
        end
        if event['primary_target']['name'] == 'ruby_version'
          event['primary_target']['detail'] = session.ruby_version
        end
        if event['primary_target']['name'] == 'operating_system'
          event['secondary_target']['detail'] = session.operating_system_version
        end
        if event['primary_target']['name'] == 'ide_version'
          event['primary_target']['detail'] = nil
        end
      end

      expect(JSON.parse(session.events.to_json)).to match_array(fixture_data)
    end
  end

  context 'action completion' do
    let(:completion_context) do
      context = FastlaneCore::ActionCompletionContext.new(
        p_hash: p_hash,
        status: FastlaneCore::ActionCompletionStatus::SUCCESS,
        action_name: action_name
      )
    end

    it 'appends a completion event to the events array' do
      expect(SecureRandom).to receive(:uuid).and_return(session_id)
      expect(Time).to receive(:now).and_return(timestamp_millis)

      session = FastlaneCore::AnalyticsSession.new
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
          millis_since_epoch: timestamp_millis * 1000,
          version: 1
        }
      )
    end
  end
end
