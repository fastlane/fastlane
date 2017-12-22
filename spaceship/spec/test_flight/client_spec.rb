require 'spec_helper'
require_relative '../mock_servers'

##
# subclass the client we want to test so we can make test-methods easier
class TestFlightTestClient < Spaceship::TestFlight::Client
  def test_request(some_param: nil, another_param: nil)
    assert_required_params(__method__, binding)
  end

  def handle_response(response)
    super(response)
  end
end

describe Spaceship::TestFlight::Client do
  subject { TestFlightTestClient.new(current_team_id: 'fake-team-id') }
  let(:app_id) { 'some-app-id' }
  let(:platform) { 'ios' }

  context '#assert_required_params' do
    it 'requires named parameters to be passed' do
      expect do
        subject.test_request(some_param: 1)
      end.to raise_error(NameError)
    end
  end

  context '#handle_response' do
    it 'handles successful responses with json' do
      response = double('Response', status: 200)
      allow(response).to receive(:body).and_return({ 'data' => 'value' })
      expect(subject.handle_response(response)).to eq('value')
    end

    it 'handles successful responses with no data' do
      response = double('Response', body: '', status: 201)
      expect(subject.handle_response(response)).to eq(nil)
    end

    it 'raises an exception on an API error' do
      response = double('Response', status: 400)
      allow(response).to receive(:body).and_return({ 'data' => nil, 'error' => 'Bad Request' })
      expect do
        subject.handle_response(response)
      end.to raise_error(Spaceship::Client::UnexpectedResponse)
    end

    it 'raises an exception on a HTTP error' do
      response = double('Response', body: '<html>Server Error</html>', status: 400)
      expect do
        subject.handle_response(response)
      end.to raise_error(Spaceship::Client::UnexpectedResponse)
    end

    it 'raises an InternalServerError exception on a HTTP 500 error' do
      response = double('Response', body: '<html>Server Error</html>', status: 500)
      expect do
        subject.handle_response(response)
      end.to raise_error(Spaceship::Client::InternalServerError)
    end
  end

  ##
  # @!group Build Trains API
  ##

  context '#get_build_trains' do
    it 'executes the request' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/platforms/ios/trains') {}
      subject.get_build_trains(app_id: app_id, platform: platform)
      expect(WebMock).to have_requested(:get, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/platforms/ios/trains')
    end
  end

  context '#get_builds_for_train' do
    it 'executes the request' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/platforms/ios/trains/1.0/builds') {}
      subject.get_builds_for_train(app_id: app_id, platform: platform, train_version: '1.0')
      expect(WebMock).to have_requested(:get, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/platforms/ios/trains/1.0/builds')
    end

    it 'retries requests' do
      allow(subject).to receive(:request) { raise Faraday::ParsingError, 'Boom!' }
      expect(subject).to receive(:request).exactly(2).times
      begin
        subject.get_builds_for_train(app_id: app_id, platform: platform, train_version: '1.0', retry_count: 2)
      rescue
      end
    end
  end

  ##
  # @!group Builds API
  ##

  context '#get_build' do
    it 'executes the request' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/builds/1') {}
      subject.get_build(app_id: app_id, build_id: 1)
      expect(WebMock).to have_requested(:get, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/builds/1')
    end
  end

  context '#put_build' do
    let(:build) { double('Build', to_json: "") }
    it 'executes the request' do
      MockAPI::TestFlightServer.put('/testflight/v2/providers/fake-team-id/apps/some-app-id/builds/1') {}
      subject.put_build(app_id: app_id, build_id: 1, build: build)
      expect(WebMock).to have_requested(:put, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/builds/1')
    end
  end

  context '#expire_build' do
    let(:build) { double('Build', to_json: "") }
    it 'executes the request' do
      MockAPI::TestFlightServer.post('/testflight/v2/providers/fake-team-id/apps/some-app-id/builds/1/expire') {}
      subject.expire_build(app_id: app_id, build_id: 1, build: build)
      expect(WebMock).to have_requested(:post, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/builds/1/expire')
    end
  end

  ##
  # @!group Groups API
  ##

  context '#create_group_for_app' do
    let(:group_name) { 'some-group-name' }
    it 'executes the request' do
      MockAPI::TestFlightServer.post('/testflight/v2/providers/fake-team-id/apps/some-app-id/groups') {}
      subject.create_group_for_app(app_id: app_id, group_name: group_name)
      expect(WebMock).to have_requested(:post, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/groups')
    end
  end

  context '#get_groups' do
    it 'executes the request' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/groups') {}
      subject.get_groups(app_id: app_id)
      expect(WebMock).to have_requested(:get, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/groups')
    end
  end

  context '#add_group_to_build' do
    it 'executes the request' do
      MockAPI::TestFlightServer.put('/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/builds/fake-build-id') {}
      subject.add_group_to_build(app_id: app_id, group_id: 'fake-group-id', build_id: 'fake-build-id')
      expect(WebMock).to have_requested(:put, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/builds/fake-build-id')
    end
  end

  ##
  # @!group Testers API
  ##

  context '#testers_for_app' do
    it 'executes the request' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/testers') {}
      subject.testers_for_app(app_id: app_id)
      expect(WebMock).to have_requested(:get, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/testers?limit=40&order=asc&sort=email')
    end
  end

  context '#search_for_tester_in_app' do
    it 'executes the request' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/testers') {}
      subject.search_for_tester_in_app(app_id: app_id, text: "fake+tester+text")
      expect(WebMock).to have_requested(:get, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/testers?order=asc&search=fake%2Btester%2Btext&sort=status')
    end
  end

  context '#delete_tester_from_app' do
    it 'executes the request' do
      MockAPI::TestFlightServer.delete('/testflight/v2/providers/fake-team-id/apps/some-app-id/testers/fake-tester-id') {}
      subject.delete_tester_from_app(app_id: app_id, tester_id: 'fake-tester-id')
      expect(WebMock).to have_requested(:delete, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/testers/fake-tester-id')
    end
  end

  context '#create_app_level_tester' do
    let(:tester) { double('Tester', email: 'fake@email.com', first_name: 'Fake', last_name: 'Name') }
    it 'executes the request' do
      MockAPI::TestFlightServer.post('/testflight/v2/providers/fake-team-id/apps/some-app-id/testers') {}
      subject.create_app_level_tester(app_id: app_id, first_name: tester.first_name, last_name: tester.last_name, email: tester.email)
      expect(WebMock).to have_requested(:post, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/testers')
    end
  end

  context '#post_tester_to_group' do
    it 'executes the request' do
      MockAPI::TestFlightServer.post('/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/testers') {}
      tester = OpenStruct.new({ first_name: "Josh", last_name: "Taquitos", email: "taquitos@google.com" })
      subject.post_tester_to_group(app_id: app_id,
                                    email: tester.email,
                               first_name: tester.first_name,
                                last_name: tester.last_name,
                                 group_id: 'fake-group-id')
      expect(WebMock).to have_requested(:post, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/testers').
        with(body: '[{"email":"taquitos@google.com","firstName":"Josh","lastName":"Taquitos"}]')
    end
  end

  context '#delete_tester_from_group' do
    it 'executes the request' do
      MockAPI::TestFlightServer.delete('/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/testers/fake-tester-id') {}
      subject.delete_tester_from_group(app_id: app_id, tester_id: 'fake-tester-id', group_id: 'fake-group-id')
      expect(WebMock).to have_requested(:delete, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/testers/fake-tester-id')
    end
  end

  ##
  # @!group AppTestInfo
  ##

  context '#get_app_test_info' do
    it 'executes the request' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/testInfo') {}
      subject.get_app_test_info(app_id: app_id)
      expect(WebMock).to have_requested(:get, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/testInfo')
    end
  end

  context '#put_app_test_info' do
    let(:app_test_info) { double('AppTestInfo', to_json: '') }
    it 'executes the request' do
      MockAPI::TestFlightServer.put('/testflight/v2/providers/fake-team-id/apps/some-app-id/testInfo') {}
      subject.put_app_test_info(app_id: app_id, app_test_info: app_test_info)
      expect(WebMock).to have_requested(:put, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/testInfo')
    end
  end
end
