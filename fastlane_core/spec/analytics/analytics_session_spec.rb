describe FastlaneCore::AnalyticsSession do
  let(:oauth_app_name) { 'fastlane-tests' }
  let(:configuration_language) { 'ruby' }
  let(:p_hash) { 'some.phash.value' }
  let(:session_id) { 's0m3s3ss10n1D' }
  let(:timestamp_millis) { 1_507_142_046 }
  let(:fixture_dirname) do
    dirname = File.expand_path(File.dirname(__FILE__))
    File.join(dirname, './fixtures/')
  end

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
          configuration_language: configuration_language
        )
      end

      let(:fixture_data) do
        JSON.parse(File.read(File.join(fixture_dirname, '/launched.json')))
      end

      it "adds all events to the session's events array" do
        expect(SecureRandom).to receive(:uuid).and_return(session_id)
        allow(Time).to receive(:now).and_return(timestamp_millis)

        # Stub out calls related to the execution environment
        session = FastlaneCore::AnalyticsSession.new
        session.is_fastfile = true
        allow(session).to receive(:oauth_app_name).and_return(oauth_app_name)
        expect(session).to receive(:fastlane_version).and_return('2.5.0')
        expect(session).to receive(:ruby_version).and_return('2.4.0')
        expect(session).to receive(:operating_system_version).and_return('10.12')
        expect(session).to receive(:fastfile_id).and_return('')

        expect(FastlaneCore::Helper).to receive(:xcode_version).and_return('9.0.1')

        session.action_launched(launch_context: launch_context)

        parsed_events = JSON.parse(session.events.to_json)
        parsed_events.zip(fixture_data).each do |parsed, fixture|
          expect(parsed).to eq(fixture)
        end
      end

      it 'is not executed via Fastfile' do
        expect(SecureRandom).to receive(:uuid).and_return(session_id)
        allow(Time).to receive(:now).and_return(timestamp_millis)

        # Stub out calls related to the execution environment
        session = FastlaneCore::AnalyticsSession.new
        allow(session).to receive(:oauth_app_name).and_return(oauth_app_name)
        expect(session).to receive(:fastlane_version).and_return('2.5.0')
        expect(session).to receive(:ruby_version).and_return('2.4.0')
        expect(session).to receive(:operating_system_version).and_return('10.12')

        session.action_launched(launch_context: launch_context)

        fastfile_events = session.events.select { |event| event[:primary_target][:name] == 'fastfile' }
        expect(fastfile_events.count).to eq(1)
        expect(fastfile_events.first[:primary_target][:detail]).to eq(false.to_s)
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

        session = FastlaneCore::AnalyticsSession.new
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
          platform: 'ios',
          configuration_language: configuration_language
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
          platform: 'ios',
          configuration_language: configuration_language
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
        expect(session).to receive(:fastfile_id).and_return('').twice

        expect(FastlaneCore::Helper).to receive(:xcode_version).and_return('9.0.1').twice

        session.action_launched(launch_context: action_1_launch_context)
        session.action_completed(completion_context: action_1_completion_context)
        session.action_launched(launch_context: action_2_launch_context)
        session.action_completed(completion_context: action_2_completion_context)

        expected_final_array = fixture_data_action_1_launched + [fixture_data_action_1_completed] + fixture_data_action_2_launched + [fixture_data_action_2_completed]
        parsed_events = JSON.parse(session.events.to_json)

        parsed_events.zip(expected_final_array).each do |parsed, fixture|
          expect(parsed).to eq(fixture)
        end
      end
    end
  end

  context 'mock Fastfile executions' do
    before(:each) do
      FastlaneCore.reset_session
    end

    let(:fixture_data) do
      events = JSON.parse(File.read(File.join(fixture_dirname, '/launched.json')))
      events.each { |event| event["action"]["detail"] = 'lane_switch' }
      events
    end

    let(:guesser) { FastlaneCore::AppIdentifierGuesser.new }

    it 'records more than one action from a Fastfile' do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
      ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
      version_events = FastlaneCore.session.events.select do |event|
        event[:primary_target][:name] == 'fastlane_version'
      end
      expect(version_events.count).to eq(4)
      action_names = version_events.map { |event| event[:action][:detail] }
      expect(action_names).to match_array([
                                            'default_platform',
                                            'frameit',
                                            'team_id',
                                            'team_id'
                                          ])
    end

    it 'has a completion event for each action' do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
      ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
      completion_events = FastlaneCore.session.events.select do |event|
        event[:action][:name] == 'completed'
      end
      expect(completion_events.count).to eq(4)
      action_names = completion_events.map { |event| event[:action][:detail] }
      expect(action_names).to match_array([
                                            'default_platform',
                                            'frameit',
                                            'team_id',
                                            'team_id'
                                          ])
    end

    it 'has a fastfile value of true for each event' do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
      ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
      fastfile_events = FastlaneCore.session.events.select do |event|
        event[:primary_target][:name] == 'fastfile'
      end
      expect(fastfile_events.count).to eq(4)
      fastfile_values = fastfile_events.map { |event| event[:primary_target][:detail] }
      expect(fastfile_values).to all(be == "true")
    end
  end

  context 'opt out' do
    it "does not post the collected data if the opt-out ENV var is set" do
      with_env_values('FASTLANE_OPT_OUT_USAGE' => '1') do
        FastlaneCore.reset_session
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
        ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
        completion_events = FastlaneCore.session.events.select do |event|
          event[:action][:name] == 'completed'
        end
        expect(completion_events.count).to eq(4)
        expect(FastlaneCore.session.client).not_to(receive(:post_events))
        FastlaneCore.session.finalize_session
      end
    end
  end
end

# here are a bunch of tests we should also have
# these were scattered around, but I think we should put them in one place

# it "tracks which tool raises an error" do
#   collector.did_raise_error(:scan)

#   expect(collector.error).to eq(:scan)
#   expect(collector.crash).to be(false)
# end

# it "tracks which tool crashes" do
#   collector.did_crash(:scan)

#   expect(collector.error).to eq(:scan)
#   expect(collector.crash).to be(true)
# end
