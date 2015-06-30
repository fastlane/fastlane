require 'webmock/rspec'

def itc_read_fixture_file(filename)
  File.read(File.join('spec', 'itunes_connect', 'fixtures', filename))
end

def itc_user_agent # as this might change
  'spaceship'
end


def itc_stub_login
  # Retrieving the current login URL
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('landing_page.html'), :headers => {})

  # Actual login
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wo/4.0.1.13.3.13.3.2.1.1.3.1.1").
         with(:body => {"theAccountName"=>"spaceship@krausefx.com", "theAccountPW"=>"so_secret"},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => "", :headers => {'Set-Cookie' => itc_read_fixture_file('login_cookie_spam.txt') })
end

def itc_stub_applications
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/manageyourapps/summary").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('app_summary.json'), headers: {'Content-Type' => 'application/json'})
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    itc_stub_login
    itc_stub_applications
  end
end
