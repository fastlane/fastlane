require 'spec_helper'

describe Spaceship::Client do
  subject { Spaceship::Client.instance }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }
  describe '#api_key' do
    it 'returns the extracted api key from the login page' do
      expect(subject.api_key).to eq('2089349823abbababa98239839')
    end
  end

  describe '#login' do
    it 'returns the session cookie' do
      cookie = subject.login(username, password)
      expect(cookie).to eq('myacinfo=abcdef;')
    end
  end

  context 'authenticated' do
    before { subject.login(username, password) }
    describe '#teams' do
      let(:teams) { subject.teams }
      it 'returns the list of available teams' do
        expect(teams).to be_instance_of(Array)
        expect(teams.first.keys).to eq(['status', 'name', 'teamId', 'type', 'extendedTeamAttributes', 'teamAgent', 'memberships', 'currentTeamMember'])
      end
    end

    describe '#team_id' do
      it 'returns the default team_id' do
        expect(subject.team_id).to eq('5A997XSHAA')
      end
    end

    describe '#apps' do
      let(:apps) { subject.apps }
      it 'returns a list of apps' do
        expect(apps).to be_instance_of(Array)
        expect(apps.first.keys).to eq(["appIdId", "name", "appIdPlatform", "prefix", "identifier", "isWildCard", "isDuplicate", "features", "enabledFeatures", "isDevPushEnabled", "isProdPushEnabled", "associatedApplicationGroupsCount", "associatedCloudContainersCount", "associatedIdentifiersCount"])
      end
    end

    describe '#app' do
      it 'returns an app hash matching on the bundle_id' do
        expect(subject.app('B7JBD8LHAA')).to eq({
          "appIdId" => "B7JBD8LHAA",
          "appIdPlatform" => "ios",
          "associatedApplicationGroupsCount" => nil,
          "associatedCloudContainersCount" => nil,
          "associatedIdentifiersCount" => nil,
          "enabledFeatures" => [],
          "features" => {},
          "identifier" => "net.sunapps.151",
          "isDevPushEnabled" => nil,
          "isDuplicate" => false,
          "isProdPushEnabled" => nil,
          "isWildCard" => false,
          "name" => "The App Name",
          "prefix" => "5A997XSHK2",
        })
      end
    end

    describe '#devices' do
      let(:devices) { subject.devices }
      it 'returns a list of device hashes' do
        expect(devices).to be_instance_of(Array)
        expect(devices.first.keys).to eq(["deviceId", "name", "deviceNumber", "devicePlatform", "status"])
      end
    end
  end
end
