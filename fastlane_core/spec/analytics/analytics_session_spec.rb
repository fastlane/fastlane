describe FastlaneCore::AnalyticsSession do
  let(:configuration_language) { 'ruby' }
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
          configuration_language: configuration_language
        )
      end

      it 'analytics session: launch' do
        expect(SecureRandom).to receive(:uuid).and_return(session_id)

        # Stub out calls related to the execution environment
        client = double("ingester_client")
        session = FastlaneCore::AnalyticsSession.new(analytics_ingester_client: client)
        expect(client).to receive(:post_event).with({
            client_id: p_hash,
            category: :undefined,
            action: :launch,
            label: nil,
            value: nil
        })

        session.action_launched(launch_context: launch_context)
      end
    end
  end

  # context 'mock Fastfile executions' do
  #   before(:each) do
  #     FastlaneCore.reset_session
  #   end

  #   let(:fixture_data) do
  #     events = JSON.parse(File.read(File.join(fixture_dirname, '/launched.json')))
  #     events.each { |event| event["action"]["detail"] = 'lane_switch' }
  #     events
  #   end

  #   let(:guesser) { FastlaneCore::AppIdentifierGuesser.new }

  #   it 'records more than one action from a Fastfile' do
  #     allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
  #     ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
  #     version_events = FastlaneCore.session.events.select do |event|
  #       event[:primary_target][:name] == 'fastlane_version'
  #     end
  #     expect(version_events.count).to eq(4)
  #     action_names = version_events.map { |event| event[:action][:detail] }
  #     expect(action_names).to match_array([
  #                                           'default_platform',
  #                                           'frameit',
  #                                           'team_id',
  #                                           'team_id'
  #                                         ])
  #   end

  #   it 'has a completion event for each action' do
  #     allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
  #     ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
  #     completion_events = FastlaneCore.session.events.select do |event|
  #       event[:action][:name] == 'completed'
  #     end
  #     expect(completion_events.count).to eq(4)
  #     action_names = completion_events.map { |event| event[:action][:detail] }
  #     expect(action_names).to match_array([
  #                                           'default_platform',
  #                                           'frameit',
  #                                           'team_id',
  #                                           'team_id'
  #                                         ])
  #   end

  #   it 'has a fastfile value of true for each event' do
  #     allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
  #     ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
  #     fastfile_events = FastlaneCore.session.events.select do |event|
  #       event[:primary_target][:name] == 'fastfile'
  #     end
  #     expect(fastfile_events.count).to eq(4)
  #     fastfile_values = fastfile_events.map { |event| event[:primary_target][:detail] }
  #     expect(fastfile_values).to all(be == "true")
  #   end
  # end

  # context 'opt out' do
  #   it "does not post the collected data if the opt-out ENV var is set" do
  #     with_env_values('FASTLANE_OPT_OUT_USAGE' => '1') do
  #       FastlaneCore.reset_session
  #       allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
  #       ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
  #       completion_events = FastlaneCore.session.events.select do |event|
  #         event[:action][:name] == 'completed'
  #       end
  #       expect(completion_events.count).to eq(4)
  #       expect(FastlaneCore.session.client).not_to(receive(:post_events))
  #       FastlaneCore.session.finalize_session
  #     end
  #   end
  # end
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
