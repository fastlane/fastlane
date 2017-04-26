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
      response.stub(:body).and_return({ 'data' => 'value' })
      expect(subject.handle_response(response)).to eq('value')
    end

    it 'handles successful responses with no data' do
      response = double('Response', body: '', status: 201)
      expect(subject.handle_response(response)).to eq(nil)
    end

    it 'raises an exception on an API error' do
      response = double('Response', status: 400)
      response.stub(:body).and_return({ 'data' => nil, 'error' => 'Bad Request' })
      expect do
        subject.handle_response(response)
      end.to raise_error(Spaceship::Client::UnexpectedResponse)
    end

    it 'raises an exception on a HTTP error' do
      response = double('Response', body: '<html>Server Error</html>', status: 500)
      expect do
        subject.handle_response(response)
      end.to raise_error(Spaceship::Client::UnexpectedResponse)
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
  end

  ##
  # @!group Builds API
  ##

  context '#get_build' do
    it 'executes the request' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/builds/1') { }
      subject.get_build(app_id: app_id, build_id: 1)
      expect(WebMock).to have_requested(:get, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/builds/1')
    end
  end

  context '#put_build' do
    let(:build) { double('Build', to_json: "") }
    it 'executes the request' do
      MockAPI::TestFlightServer.put('/testflight/v2/providers/fake-team-id/apps/some-app-id/builds/1') { }
      subject.put_build(app_id: app_id, build_id: 1, build: build)
      expect(WebMock).to have_requested(:put, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/builds/1')
    end
  end

  ##
  # @!group Groups API
  ##

  context '#get_groups' do
    it 'executes the request' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/groups') { }
      subject.get_groups(app_id: app_id)
      expect(WebMock).to have_requested(:get, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/groups')
    end
  end

  context '#add_group_to_build' do
    it 'executes the request' do
      MockAPI::TestFlightServer.put('/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/builds/fake-build-id') { }
      subject.add_group_to_build(app_id: app_id, group_id: 'fake-group-id', build_id: 'fake-build-id')
      expect(WebMock).to have_requested(:put, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/builds/fake-build-id')
    end
  end
end
