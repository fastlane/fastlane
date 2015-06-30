require 'webmock/rspec'

def read_fixture_file_itc(filename)
  File.read(File.join('spec', 'itunes_connect', 'fixtures', filename))
end

def user_agent # as this might change
  'spaceship'
end


def stub_login
  # Retrieving the current login URL
  stub_request(:get, "https://itunesconnect.apple.com/").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => read_fixture_file_itc('landing_page.html'), :headers => {})

  # Actual login
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wo/4.0.1.13.3.13.3.2.1.1.3.1.1").
         with(:body => {"theAccountName"=>"spaceship@krausefx.com", "theAccountPW"=>"so_secret"},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => "", :headers => {'Set-Cookie' => read_fixture_file_itc('login_cookie_spam.txt') })
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    stub_login
    # stub_applications
  end
end
