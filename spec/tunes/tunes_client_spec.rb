require 'spec_helper'

describe Spaceship::TunesClient do
  describe '#login' do
    it 'raises an exception if authentication failed' do
      expect do
        subject.login('bad-username', 'bad-password')
      end.to raise_exception(Spaceship::Client::InvalidUserCredentialsError, "Invalid username and password combination. Used 'bad-username' as the username.")
    end

    it "raises a different exception if the server doesn't respond with any cookies" do
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wo/4.0.1.13.3.13.3.2.1.1.3.1.1").
        with(body: { "theAccountName" => "user", "theAccountPW" => "password" },
              headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'spaceship' }).
        to_return(status: 200, body: 'random Body', headers: {})

      # This response doesn't set any header information and is therefore useless
      expect do
        subject.login('user', 'password')
      end.to raise_exception(Spaceship::TunesClient::ITunesConnectError, "random Body\n")
    end

    it "raises a different exception if the server responds with cookies but they can't be parsed" do
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wo/4.0.1.13.3.13.3.2.1.1.3.1.1").
        with(body: { "theAccountName" => "user", "theAccountPW" => "password" },
              headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'spaceship' }).
        to_return(status: 200, body: 'random Body', headers: { 'Set-Cookie' => "myacinfo=asdf; That's a big mess;" })

      # This response doesn't set any header information and is therefore useless
      expect do
        subject.login('user', 'password')
      end.to raise_exception(Spaceship::TunesClient::ITunesConnectError, "random Body\nmyacinfo=asdf; That's a big mess;")
    end
  end

  describe "#send_login_request" do
    it "sets the correct cookies when getting the response" do
      expect(subject.cookie).to eq(nil)
      subject.send_login_request('spaceship@krausefx.com', 'so_secret')
      expect(subject.cookie).to eq(itc_cookie)
    end
  end

  describe "Logged in" do
    subject { Spaceship::Tunes.client }
    let(:username) { 'spaceship@krausefx.com' }
    let(:password) { 'so_secret' }

    before do
      Spaceship::Tunes.login(username, password)
    end

    it 'returns the session cookie' do
      expect(subject.cookie).to eq(itc_cookie)
    end

    it 'stores the username' do
      expect(subject.user).to eq('spaceship@krausefx.com')
    end

    it "#hostname" do
      expect(subject.class.hostname).to eq('https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/')
    end

    it "#login_url" do
      expect(subject.login_url).to eq("https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wo/4.0.1.13.3.13.3.2.1.1.3.1.1")
    end

    describe "#handle_itc_response" do
      it "raises an exception if something goes wrong" do
        data = JSON.parse(itc_read_fixture_file('update_app_version_failed.json'))['data']
        expect do
          subject.handle_itc_response(data)
        end.to raise_error "The App Name you entered has already been used. The App Name you entered has already been used. You must provide an address line. There are errors on the page and for 2 of your localizations."
      end

      it "does nothing if everything works as expected and returns the original data" do
        data = JSON.parse(itc_read_fixture_file('update_app_version_success.json'))['data']
        expect(subject.handle_itc_response(data)).to eq(data)
      end
    end
  end
end
