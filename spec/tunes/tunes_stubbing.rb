require 'webmock/rspec'

def itc_read_fixture_file(filename)
  File.read(File.join('spec', 'tunes', 'fixtures', filename))
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

  # Failed login attempts
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wo/4.0.1.13.3.13.3.2.1.1.3.1.1").
         with(:body => {"theAccountName"=>"bad-username", "theAccountPW"=>"bad-password"},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => "", :headers => {} )
end

def itc_stub_applications
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/manageyourapps/summary").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('app_summary.json'), headers: {'Content-Type' => 'application/json'})


  # Create Version stubbing
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/version/create/1013943394").
         with(:body => "{\"version\":\"0.1\"}",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('create_version_success.json'), headers: {'Content-Type' => 'application/json'})

  # Create Application
  # Pre-Fill request
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/?appType=ios").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('create_application_prefill_request.json'), headers: {'Content-Type' => 'application/json'})
  # Actual sucess request
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/?appType=ios").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('create_application_success.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_applications_first_create
  # Create First Application
  # Pre-Fill request
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/?appType=ios").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('create_application_prefill_first_request.json'), headers: {'Content-Type' => 'application/json'})
  # end
end

def itc_stub_applications_broken_first_create
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/?appType=ios").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('create_application_first_broken.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_broken_create
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/?appType=ios").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('create_application_broken.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_broken_create_wildcard
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/?appType=ios").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('create_application_wildcard_broken.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_app_versions
  # Receiving app version
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/version/898536088?v=").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('app_version.json'), headers: {'Content-Type' => 'application/json'})
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/version/898536088?v=live").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('app_version.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_app_submissions
  # Start app submission
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/version/submit/start").
         to_return(:status => 200, :body => itc_read_fixture_file('app_submission/start_success.json'), headers: {'Content-Type' => 'application/json'})

  # Complete app submission
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/version/submit/complete").
         to_return(:status => 200, :body => itc_read_fixture_file('app_submission/complete_success.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_app_submissions_already_submitted
  # Start app submission
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/version/submit/start").
         to_return(:status => 200, :body => itc_read_fixture_file('app_submission/start_success.json'), headers: {'Content-Type' => 'application/json'})

  # Complete app submission
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/version/submit/complete").
         to_return(:status => 200, :body => itc_read_fixture_file('app_submission/complete_failed.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_app_submissions_invalid
  # Start app submission
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/version/submit/start").
         to_return(:status => 200, :body => itc_read_fixture_file('app_submission/start_failed.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_resolution_center
  # Called from the specs to simulate invalid server responses
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/resolutionCenter?v=latest").
    with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
    to_return(:status => 200, :body => itc_read_fixture_file('app_resolution_center.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_build_trains
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('build_trains.json'), headers: {'Content-Type' => 'application/json'})
  # Update build trains
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/").
    with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
    to_return(:status => 200, :body => itc_read_fixture_file('build_trains.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_testers
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/users/pre/int").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('testers/get_internal.json'), headers: {'Content-Type' => 'application/json'})
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/users/pre/ext").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('testers/get_external.json'), headers: {'Content-Type' => 'application/json'})
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/user/internalTesters/898536088/").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('testers/existing_internal_testers.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_testflight
  # Reject review
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/0.9.10/builds/123123/reject").
         with(:body => "{}",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => "{}", headers: {'Content-Type' => 'application/json'})

  # Prepare submission
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/0.9.10/builds/123123/submit/start").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('testflight_submission_start.json'), headers: {'Content-Type' => 'application/json'})
  # First step of submission
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/0.9.10/builds/123123/submit/start").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => itc_read_fixture_file('testflight_submission_submit.json'), headers: {'Content-Type' => 'application/json'})
end


def itc_stub_resolution_center_valid
  # Called from the specs to simulate valid server responses
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/resolutionCenter?v=latest").
    with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Cookie'=>'myacinfo=DAWTKN;woinst=3363;wosid=xBJMOVttbAQ1Cwlt8ktafw', 'User-Agent'=>'spaceship'}).
    to_return(:status => 200, :body => itc_read_fixture_file('app_resolution_center_valid.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_invalid_update
  # Called from the specs to simulate invalid server responses
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/version/save/898536088?v=").
         to_return(:status => 200, :body => itc_read_fixture_file('update_app_version_failed.json'), headers: {'Content-Type' => 'application/json'})
end

def itc_stub_valid_update
  # Called from the specs to simulate valid server responses
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/version/save/898536088?v=").
         to_return(:status => 200, :body => itc_read_fixture_file('update_app_version_success.json'), headers: {'Content-Type' => 'application/json'})
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    itc_stub_login
    itc_stub_applications
    itc_stub_app_versions
    itc_stub_build_trains
    itc_stub_testers
    itc_stub_testflight
  end
end
