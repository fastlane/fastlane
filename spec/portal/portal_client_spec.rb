require 'spec_helper'

describe Spaceship::Client do
  before { Spaceship.login }
  subject { Spaceship.client }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  describe '#api_key' do
    let(:path) { "/tmp/spaceship_api_key.txt" }
    it 'returns the extracted api key from the login page' do
      expect(subject.api_key).to eq('0123abcdef123123')
    end

    it "stores a cached result in /tmp" do
      File.delete(path)
      expect(subject.api_key).to eq('0123abcdef123123')
      expect(File.read(path)).to eq("0123abcdef123123")
    end

    it "uses the cached api key if it exists" do
      new_value = "NewValue"
      File.write(path, new_value)
      expect(subject.api_key).to eq(new_value)
    end

    after do
      File.delete(path)
    end
  end

  describe '#login' do
    it 'returns the session cookie' do
      subject.login(username, password)
      expect(subject.cookie).to eq('myacinfo=abcdef;')
    end

    it 'raises an exception if authentication failed' do
      expect {
        subject.login('bad-username', 'bad-password')
      }.to raise_exception(Spaceship::Client::InvalidUserCredentialsError)
    end

    it "raises an exception if no login data is provided at all" do
      expect {
        subject.login('', '')
      }.to raise_exception(Spaceship::Client::NoUserCredentialsError)
    end
  end

  context 'authenticated' do
    before { subject.login(username, password) }
    describe '#teams' do
      let(:teams) { subject.teams }
      it 'returns the list of available teams' do
        expect(teams).to be_instance_of(Array)
        expect(teams.first.keys).to eq( ["status", "teamId", "type", "extendedTeamAttributes", "teamAgent", "memberships", "currentTeamMember", "name"])
      end
    end

    describe '#team_id' do
      it 'returns the default team_id' do
        expect(subject.team_id).to eq('XXXXXXXXXX')
      end

      it "set custom Team ID" do
        team_id = "ABCDEF"
        subject.team_id = team_id
        expect(subject.team_id).to eq(team_id)
      end

      it "shows a warning when user is in multiple teams and didn't call select_team" do
        adp_stub_multiple_teams
        expect(subject.team_id).to eq("XXXXXXXXXX")
      end
    end

    describe "csrf_tokens" do
      it "uses the stored token for all upcoming requests" do
        # Temporary stub a request to require the csrf_tokens
        stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action').
            with(body: {teamId: 'XXXXXXXXXX', pageSize: "10", pageNumber: "1", sort: 'name=asc'}, headers: {'Cookie' => 'myacinfo=abcdef;', 'csrf' => 'top_secret', 'csrf_ts' => '123123'}).
            to_return(status: 200, body: adp_read_fixture_file('listDevices.action.json'), headers: {'Content-Type' => 'application/json'})

        # Hard code the tokens
        allow(subject).to receive(:csrf_tokens).and_return({csrf: 'top_secret', csrf_ts: '123123'})
        allow(subject).to receive(:page_size).and_return(10) # to have a seperate stubbing

        expect(subject.devices.count).to eq(4)
      end
    end

    describe '#apps' do
      let(:apps) { subject.apps }
      it 'returns a list of apps' do
        expect(apps).to be_instance_of(Array)
        expect(apps.first.keys).to eq(["appIdId", "name", "appIdPlatform", "prefix", "identifier", "isWildCard", "isDuplicate", "features", "enabledFeatures", "isDevPushEnabled", "isProdPushEnabled", "associatedApplicationGroupsCount", "associatedCloudContainersCount", "associatedIdentifiersCount"])
      end
    end

    describe "#team_information" do
      it 'returns all available information' do
        s = subject.team_information
        expect(s['status']).to eq('active')
        expect(s['type']).to eq('Company/Organization')
        expect(s['name']).to eq('SpaceShip')
      end
    end

    describe "#in_house?" do
      it 'returns false for normal accounts' do
        expect(subject.in_house?).to eq(false)
      end

      it 'returns true for enterprise accounts' do
        adp_stub_multiple_teams

        subject.team_id = 'SecondTeam'
        expect(subject.in_house?).to eq(true)
      end
    end

    describe '#create_app' do
      it 'should make a request create an explicit app id' do
        response = subject.create_app!(:explicit, 'Production App', 'tools.fastlane.spaceship.some-explicit-app')
        expect(response['isWildCard']).to eq(false)
        expect(response['name']).to eq('Production App')
        expect(response['identifier']).to eq('tools.fastlane.spaceship.some-explicit-app')
      end

      it 'should make a request create a wildcard app id' do
        response = subject.create_app!(:wildcard, 'Development App', 'tools.fastlane.spaceship.*')
        expect(response['isWildCard']).to eq(true)
        expect(response['name']).to eq('Development App')
        expect(response['identifier']).to eq('tools.fastlane.spaceship.*')
      end
    end

    describe '#delete_app!' do
      it 'should make a request to delete the app' do
        response = subject.delete_app!('LXD24VUE49')
        expect(response['resultCode']).to eq(0)
      end
    end

    describe "#paging" do
      it "default page size is correct" do
        expect(subject.page_size).to eq(500)
      end

      it "Properly pages if required with support for a custom page size" do
        allow(subject).to receive(:page_size).and_return(8)

        expect(subject.devices.count).to eq(9)
        expect(subject.devices.last['name']).to eq("The last phone")
      end
    end

    describe '#devices' do
      let(:devices) { subject.devices }
      it 'returns a list of device hashes' do
        expect(devices).to be_instance_of(Array)
        expect(devices.first.keys).to eq(["deviceId", "name", "deviceNumber", "devicePlatform", "status", "model", "deviceClass"])
      end
    end

    describe '#certificates' do
      let(:certificates) { subject.certificates(["5QPB9NHCEI"]) }
      it 'returns a list of certificates hashes' do
        expect(certificates).to be_instance_of(Array)
        expect(certificates.first.keys).to eq(["certRequestId", "name", "statusString", "dateRequestedString", "dateRequested", "dateCreated", "expirationDate", "expirationDateString", "ownerType", "ownerName", "ownerId", "canDownload", "canRevoke", "certificateId", "certificateStatusCode", "certRequestStatusCode", "certificateTypeDisplayId", "serialNum", "typeString"])
      end
    end

    describe "#create_device" do
      it "works as expected when the name is free" do
        device = subject.create_device!("Demo Device", "7f6c8dc83d77134b5a3a1c53f1202b395b04482b")
        expect(device['name']).to eq("Demo Device")
        expect(device['deviceNumber']).to eq("7f6c8dc83d77134b5a3a1c53f1202b395b04482b")
        expect(device['devicePlatform']).to eq('ios')
        expect(device['status']).to eq('c')
      end
    end

    describe "#create_provisioning_profile" do
      it "works when the name is free" do
        response = subject.create_provisioning_profile!("net.sunapps.106 limited", "limited", 'R9YNDTPLJX', ['C8DL7464RQ'], ['C8DLAAAARQ'])
        expect(response.keys).to include('name', 'status', 'type', 'appId', 'deviceIds')
        expect(response['distributionMethod']).to eq('limited')
      end

      it "works when the name is already taken" do
        error_text = 'Multiple profiles found with the name &#x27;Test Name 3&#x27;.  Please remove the duplicate profiles and try again.\nThere are no current certificates on this team matching the provided certificate IDs.' # not ", as this would convert the \n
        expect {
          response = subject.create_provisioning_profile!("taken", "limited", 'R9YNDTPLJX', ['C8DL7464RQ'], ['C8DLAAAARQ'])
        }.to raise_error(Spaceship::Client::UnexpectedResponse, error_text)
      end
    end

    describe '#delete_provisioning_profile!' do
      it 'makes a requeset to delete a provisioning profile' do
        response = subject.delete_provisioning_profile!('2MAY7NPHRU')
        expect(response['resultCode']).to eq(0)
      end
    end

    describe '#create_certificate' do
      let(:csr) { adp_read_fixture_file('certificateSigningRequest.certSigningRequest')}
      it 'makes a request to create a certificate' do
        response = subject.create_certificate!('BKLRAVXMGM', csr, '2HNR359G63')
        expect(response.keys).to include('certificateId', 'certificateType', 'statusString', 'expirationDate', 'certificate')
      end
    end

    describe '#revoke_certificate' do
      it 'makes a revoke request and returns the revoked certificate' do
        response = subject.revoke_certificate!('XC5PH8DAAA', 'R58UK2EAAA')
        expect(response.first.keys).to include('certificateId', 'certificateType', 'certificate')
      end
    end
  end
end
