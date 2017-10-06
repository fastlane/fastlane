describe FastlaneCore::AnalyticsSession do
  let(:oauth_app_name) { 'fastlane-tests' }
  let(:p_hash) { 'some.phash.value' }
  let(:session_id) { 's0m3s3ss10n1D' }
  let(:timestamp_millis) { 1_507_142_046 }
  let(:fixture_dirname) do
    dirname = File.expand_path(File.dirname(__FILE__))
    File.join(dirname, './fixtures/')
  end

  context 'single action execution' do
    let(:session) { FastlaneCore::AnalyticsSession.new }
    let(:action_name) { 'some_action' }

    context 'action launch' do
      let(:launch_context) do
        FastlaneCore::ActionLaunchContext.new(
          action_name: action_name,
          p_hash: p_hash,
          platform: 'ios'
        )
      end

      let(:fixture_data) do
        JSON.parse(File.read(File.join(fixture_dirname, '/launched.json')))
      end

      it "adds all events to the session's events array" do
        expect(SecureRandom).to receive(:uuid).and_return(session_id)
        allow(Time).to receive(:now).and_return(timestamp_millis)

        # Stub out calls related to the execution environment
        session.is_fastfile = true
        allow(session).to receive(:oauth_app_name).and_return(oauth_app_name)
        expect(session).to receive(:fastlane_version).and_return('2.5.0')
        expect(session).to receive(:ruby_version).and_return('2.4.0')
        expect(session).to receive(:operating_system_version).and_return('10.12')
        expect(session).to receive(:ide_version).and_return('Xcode 9')

        session.action_launched(launch_context: launch_context)
        expect(JSON.parse(session.events.to_json)).to match_array(fixture_data)
      end
    end

    context 'action completion' do
      let(:completion_context) do
        FastlaneCore::ActionCompletionContext.new(
          p_hash: p_hash,
          status: FastlaneCore::ActionCompletionStatus::SUCCESS,
          action_name: action_name
        )
      end

      let(:fixture_data) do
        event = JSON.parse(File.read(File.join(fixture_dirname, '/completed_success.json')))
        event["action"]["detail"] = action_name
        event
      end

      it 'appends a completion event to the events array' do
        expect(SecureRandom).to receive(:uuid).and_return(session_id)
        expect(Time).to receive(:now).and_return(timestamp_millis)

        expect(session).to receive(:oauth_app_name).and_return(oauth_app_name)

        session.action_completed(completion_context: completion_context)
        expect(JSON.parse(session.events.last.to_json)).to eq(fixture_data)
      end
    end
  end

  context 'two action execution' do
    let(:session) { FastlaneCore::AnalyticsSession.new }
    let(:action_1_name) { 'some_action1' }
    let(:action_2_name) { 'some_action2' }

    context 'action launch' do
      let(:action_1_launch_context) do
        FastlaneCore::ActionLaunchContext.new(
          action_name: action_1_name,
          p_hash: p_hash,
          platform: 'ios'
        )
      end
      let(:action_1_completion_context) do
        FastlaneCore::ActionCompletionContext.new(
          p_hash: p_hash,
          status: FastlaneCore::ActionCompletionStatus::SUCCESS,
          action_name: action_1_name
        )
      end
      let(:action_2_launch_context) do
        FastlaneCore::ActionLaunchContext.new(
          action_name: action_2_name,
          p_hash: p_hash,
          platform: 'ios'
        )
      end
      let(:action_2_completion_context) do
        FastlaneCore::ActionCompletionContext.new(
          p_hash: p_hash,
          status: FastlaneCore::ActionCompletionStatus::SUCCESS,
          action_name: action_2_name
        )
      end
      let(:fixture_data_action_1_launched) do
        events = JSON.parse(File.read(File.join(fixture_dirname, '/launched.json')))
        events.each { |event| event["action"]["detail"] = action_1_name }
        events
      end
      let(:fixture_data_action_2_launched) do
        events = JSON.parse(File.read(File.join(fixture_dirname, '/launched.json')))
        events.each { |event| event["action"]["detail"] = action_2_name }
        events
      end
      let(:fixture_data_action_1_completed) do
        event = JSON.parse(File.read(File.join(fixture_dirname, '/completed_success.json')))
        event["action"]["detail"] = action_1_name
        event
      end
      let(:fixture_data_action_2_completed) do
        event = JSON.parse(File.read(File.join(fixture_dirname, '/completed_success.json')))
        event["action"]["detail"] = action_2_name
        event
      end

      it "adds all events to the session's events array" do
        expect(SecureRandom).to receive(:uuid).and_return(session_id)
        allow(Time).to receive(:now).and_return(timestamp_millis)

        # Stub out calls related to the execution environment
        session.is_fastfile = true
        allow(session).to receive(:oauth_app_name).and_return(oauth_app_name)
        expect(session).to receive(:fastlane_version).and_return('2.5.0').twice
        expect(session).to receive(:ruby_version).and_return('2.4.0').twice
        expect(session).to receive(:operating_system_version).and_return('10.12').twice
        expect(session).to receive(:ide_version).and_return('Xcode 9').twice

        session.action_launched(launch_context: action_1_launch_context)
        session.action_completed(completion_context: action_1_completion_context)
        session.action_launched(launch_context: action_2_launch_context)
        session.action_completed(completion_context: action_2_completion_context)

        expected_final_array = fixture_data_action_1_launched + [fixture_data_action_1_completed] + fixture_data_action_2_launched + [fixture_data_action_2_completed]
        expect(JSON.parse(session.events.to_json)).to match_array(expected_final_array)
      end
    end
  end
end
