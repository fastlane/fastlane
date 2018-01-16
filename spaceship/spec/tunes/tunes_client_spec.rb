describe Spaceship::TunesClient do
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
      expect(subject.class.hostname).to eq('https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/')
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
  end

  describe "CI" do
    it "crashes when running in non-interactive shell" do
      expect(FastlaneCore::Helper).to receive(:ci?).and_return(true)
      provider = { 'contentProvider' => { 'name' => 'Tom', 'contentProviderId' => 1234 } }
      allow(subject).to receive(:teams).and_return([provider, provider]) # pass it twice, to call the team selection
      expect { subject.select_team }.to raise_error("Multiple iTunes Connect Teams found; unable to choose, terminal not ineractive!")
    end
  end
end
