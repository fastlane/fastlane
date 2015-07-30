require 'spec_helper'

describe Spaceship::TunesClient do
  before { Spaceship::Tunes.login }
  subject { Spaceship::Tunes.client }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    subject.cookie = nil
  end

  it "#hostname" do
    expect(subject.class.hostname).to eq('https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/')
  end

  it "#login_url" do
    expect(subject.login_url).to eq("https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wo/4.0.1.13.3.13.3.2.1.1.3.1.1")
  end

  describe '#login' do
    it 'returns the session cookie' do
      subject.login(username, password)
      expect(subject.cookie).to eq('myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw')
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

  describe "#send_login_request" do
    it "sets the correct cookies when getting the response" do
      expect(subject.cookie).to eq(nil)
      subject.send_login_request(username, password)
      expect(subject.cookie).to eq('myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw')
    end
  end

  describe "#handle_itc_response" do
    it "raises an exception if something goes wrong" do
      data = JSON.parse(itc_read_fixture_file('update_app_version_failed.json'))['data']
      expect {
        subject.handle_itc_response(data)
      }.to raise_error "The App Name you entered has already been used. The App Name you entered has already been used. You must provide an address line. There are errors on the page and for 2 of your localizations."
    end

    it "does nothing if everything works as expected and returns the original data" do
      data = JSON.parse(itc_read_fixture_file('update_app_version_success.json'))['data']
      expect(subject.handle_itc_response(data)).to eq(data)
    end
  end
end
