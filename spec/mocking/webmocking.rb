WebMock.disable_net_connect!(:allow => 'codeclimate.com')

# iTunes Lookup API
RSpec.configure do |config|
  config.before(:each) do
    stub_spaceship

    # iTunes Lookup API by Apple ID
    ["invalid", "", 0, '284882215'].each do |current|
      stub_request(:get, "https://itunes.apple.com/lookup?id=#{current.to_s}").
           with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
           to_return(:status => 200, :body => File.read("spec/responses/itunesLookup-#{current.to_s}.json"), :headers => {})
    end

    # iTunes Lookup API by App Identifier
    stub_request(:get, "https://itunes.apple.com/lookup?bundleId=com.facebook.Facebook").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => File.read("spec/responses/itunesLookup-com.facebook.Facebook.json"), :headers => {})


    stub_request(:get, "https://itunes.apple.com/lookup?bundleId=net.sunapps.54").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => File.read("spec/responses/itunesLookup-com.facebook.Facebook.json"), :headers => {})

    stub_request(:get, "https://itunes.apple.com/lookup?bundleId=net.sunapps.invalid").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => File.read("spec/responses/itunesLookup-net.sunapps.invalid.json"), :headers => {})

    ['at.felixkrause.iTanky', 'net.sunapps.321', 'net.sunapps.1'].each do |app_identifier|
      stub_request(:get, "https://itunes.apple.com/lookup?bundleId=#{app_identifier}").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => File.read("spec/responses/itunesLookup-at.felixkrause.iTanky.json"), :headers => {})
    end

    [464686641, 878567776, 794902327].each do |apple_id|
      stub_request(:get, "https://itunes.apple.com/lookup?id=#{apple_id}").
           with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
           to_return(:status => 200, :body => File.read("spec/responses/itunesLookup-com.facebook.Facebook.json"), :headers => {})
    end
  end
end