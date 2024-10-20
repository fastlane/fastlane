require 'fastlane-sirp'

describe Spaceship::TunesClient do
  let(:authentication_data) {
    '8f30ce83b660f03abb0f8570c235e0e1e1d3860a222304acf18e989bdc065dc922a141e6da4563f0' \
      '5586605b0e10535d875ca7e0fae7fe100cfe533374f29aaa803cdfb2c6194f458485e87f76988f6' \
      'cddaa1829309438e1aa9ab652b17cfc081fff40356cb3af35c621e9f37ba6e2a03e6abac5a6bfe' \
      '18ddb489412b7c56355292e6c355f8859270d04063b843d23c1ef7503c3c5dd2c56740101a3ef5' \
      'bfec6bff1e6dc55e3f70840a83a95d7b3d20ab350d0472809ce87a4e3c29ed9685eb7721dc87ba' \
      'bfadbd9e65e75d5df55547bcff98711ddeae7b8e1e6dbf529e96f7caa4b830b43575cddc52cebc' \
      '39f9522f85cbf33ac35ee59f66f48109c12fbb78d'
  }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before {
    allow_any_instance_of(SIRP::Client).to receive(:start_authentication).and_return(authentication_data)
    allow_any_instance_of(SIRP::Client).to receive(:process_challenge).and_return("1234")
  }

  describe '#login' do
    it 'raises an exception if authentication failed' do
      expect do
        subject.login('bad-username', 'bad-password')
      end.to raise_exception(Spaceship::Client::InvalidUserCredentialsError, "Invalid username and password combination. Used 'bad-username' as the username.")
    end
  end

  describe 'client' do
    it 'exposes the session cookie' do
      begin
        subject.login('bad-username', 'bad-password')
      rescue Spaceship::Client::InvalidUserCredentialsError
        expect(subject.cookie).to eq('session=invalid')
      end
    end
  end

  describe 'exception if Apple ID & Privacy not acknowledged' do
    subject { Spaceship::Tunes.client }
    let(:username) { 'spaceship@krausefx.com' }
    let(:password) { 'so_secret' }

    before(:each) do
      # Don't need to test hashcash here
      allow_any_instance_of(Spaceship::Client).to receive(:fetch_hashcash)
    end

    it 'has authType is sa' do
      expect_any_instance_of(Spaceship::Client).to receive(:request).twice.and_call_original

      response_second = double
      allow(response_second).to receive(:status).and_return(412)
      allow(response_second).to receive(:body).and_return({ "authType" => "sa" })
      expect_any_instance_of(Spaceship::Client).to receive(:request).once.and_return(response_second)

      expect do
        Spaceship::Tunes.login(username, password)
      end.to raise_exception(Spaceship::AppleIDAndPrivacyAcknowledgementNeeded, "Need to acknowledge to Apple's Apple ID and Privacy statement. Please manually log into https://appleid.apple.com (or https://appstoreconnect.apple.com) to acknowledge the statement. " \
                             "Your account might also be asked to upgrade to 2FA. Set SPACESHIP_SKIP_2FA_UPGRADE=1 for fastlane to automatically bypass 2FA upgrade if possible.")
    end

    it 'has authType of hsa' do
      expect_any_instance_of(Spaceship::Client).to receive(:request).twice.and_call_original

      response_second = double
      allow(response_second).to receive(:status).and_return(412)
      allow(response_second).to receive(:body).and_return({ "authType" => "hsa" })
      expect_any_instance_of(Spaceship::Client).to receive(:request).once.and_return(response_second)

      expect do
        Spaceship::Tunes.login(username, password)
      end.to raise_exception(Spaceship::AppleIDAndPrivacyAcknowledgementNeeded, "Need to acknowledge to Apple's Apple ID and Privacy statement. Please manually log into https://appleid.apple.com (or https://appstoreconnect.apple.com) to acknowledge the statement. " \
                             "Your account might also be asked to upgrade to 2FA. Set SPACESHIP_SKIP_2FA_UPGRADE=1 for fastlane to automatically bypass 2FA upgrade if possible.")
    end

    it 'has authType of non-sa' do
      expect_any_instance_of(Spaceship::Client).to receive(:request).twice.and_call_original

      response_second = double
      allow(response_second).to receive(:status).and_return(412)
      allow(response_second).to receive(:body).and_return({ "authType" => "hsa" })
      expect_any_instance_of(Spaceship::Client).to receive(:request).once.and_return(response_second)

      expect do
        Spaceship::Tunes.login(username, password)
      end.to raise_exception(Spaceship::AppleIDAndPrivacyAcknowledgementNeeded, "Need to acknowledge to Apple's Apple ID and Privacy statement. Please manually log into https://appleid.apple.com (or https://appstoreconnect.apple.com) to acknowledge the statement. " \
                             "Your account might also be asked to upgrade to 2FA. Set SPACESHIP_SKIP_2FA_UPGRADE=1 for fastlane to automatically bypass 2FA upgrade if possible.")
    end

    it 'has authType of hsa2' do
      expect_any_instance_of(Spaceship::Client).to receive(:request).twice.and_call_original

      response_second = double
      allow(response_second).to receive(:status).and_return(412)
      allow(response_second).to receive(:body).and_return({ "authType" => "hsa2" })
      expect_any_instance_of(Spaceship::Client).to receive(:request).once.and_return(response_second)

      expect do
        Spaceship::Tunes.login(username, password)
      end.to raise_exception(Spaceship::AppleIDAndPrivacyAcknowledgementNeeded, "Need to acknowledge to Apple's Apple ID and Privacy statement. Please manually log into https://appleid.apple.com (or https://appstoreconnect.apple.com) to acknowledge the statement. " \
                             "Your account might also be asked to upgrade to 2FA. Set SPACESHIP_SKIP_2FA_UPGRADE=1 for fastlane to automatically bypass 2FA upgrade if possible.")
    end
  end

  describe "Logged in" do
    subject { Spaceship::Tunes.client }
    let(:username) { 'spaceship@krausefx.com' }
    let(:password) { 'so_secret' }

    before do
      Spaceship::Tunes.login(username, password)
    end

    it 'stores the username' do
      expect(subject.user).to eq('spaceship@krausefx.com')
    end

    it "#hostname" do
      expect(subject.class.hostname).to eq('https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/')
    end

    describe "#handle_itc_response" do
      it "raises an exception if something goes wrong" do
        data = JSON.parse(TunesStubbing.itc_read_fixture_file('update_app_version_failed.json'))['data']
        expect do
          subject.handle_itc_response(data)
        end.to raise_error("[German]: The App Name you entered has already been used. [English]: The App Name you entered has already been used. You must provide an address line. There are errors on the page and for 2 of your localizations.")
      end

      it "does nothing if everything works as expected and returns the original data" do
        data = JSON.parse(TunesStubbing.itc_read_fixture_file('update_app_version_success.json'))['data']
        expect(subject.handle_itc_response(data)).to eq(data)
      end

      it "identifies try again later responses" do
        data = JSON.parse(TunesStubbing.itc_read_fixture_file('update_app_version_temporarily_unable.json'))['data']
        expect do
          subject.handle_itc_response(data)
        end.to raise_error(Spaceship::TunesClient::ITunesConnectTemporaryError, "We're temporarily unable to save your changes. Please try again later.")
      end
    end

    describe "associated to multiple teams" do
      let(:user_details_data) do
        {
          'availableProviders' => [
            { 'name' => 'Tom', 'providerId' => 1234, 'contentProviderPublicId' => '1111-2222-3333-4444' },
            { 'name' => 'Harry', 'providerId' => 5678, 'contentProviderPublicId' => '2222-3333-4444-5555' }
          ],
          'provider' => { 'providerId' => 1234 }
        }
      end

      it "#team_id picks team indicated by the sessionToken if select_team not called" do
        allow(subject).to receive(:user_details_data).and_return(user_details_data)
        expect(subject.team_id).to eq(1234)
      end

      it "returns team_id from legitimate team_name parameter" do
        allow(subject).to receive(:user_details_data).and_return(user_details_data)
        expect(subject.select_team(team_name: 'Harry')).to eq('5678')
      end

      it "returns team_id from environment variable" do
        stub_const('ENV', { 'FASTLANE_ITC_TEAM_NAME' => 'Harry' })
        allow(subject).to receive(:user_details_data).and_return(user_details_data)
        expect(subject.select_team).to eq('5678')
      end
    end

    describe "in-app-purchase methods" do
      before do
        stub_request(:post, "https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/123/iaps/abc/submission")
          .and_return(status: 200, body: TunesStubbing.itc_read_fixture_file("iap_submission.json"), headers: { "Content-Type" => "application/json" })
      end

      it "submits an in-app-purchase for review" do
        response = subject.submit_iap!(app_id: "123", purchase_id: "abc")
        # the response does not include any data when it is successful.
        expect(response).to eq(nil)
      end
    end

    describe "iOS app bundle methods" do
      before do
        stub_request(:get, "https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/appbundles/metadetail/1234567890")
          .and_return(status: 200, body: TunesStubbing.itc_read_fixture_file("bundle_details.json"), headers: { "Content-Type" => "application/json" })
      end

      it "requests iOS app bundle details" do
        response = subject.bundle_details(1_234_567_890)
        expect(response["adamId"]).to eq(1_234_567_890)
        expect(response["details"][0]["name"]).to eq("Fancy Bundle")
      end
    end
  end

  describe "CI" do
    it "crashes when running in non-interactive shell" do
      expect(FastlaneCore::Helper).to receive(:ci?).and_return(true)
      provider = { 'contentProvider' => { 'name' => 'Tom', 'contentProviderId' => 1234 } }
      allow(subject).to receive(:teams).and_return([provider, provider]) # pass it twice, to call the team selection
      expect { subject.select_team }.to raise_error("Multiple App Store Connect Teams found; unable to choose, terminal not interactive!")
    end
  end
end
