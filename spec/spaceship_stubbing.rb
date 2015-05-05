require 'webmock/rspec'

def read_fixture_file(filename)
  File.read(File.join('spec', 'fixtures', filename))
end

# Let the stubbing begin
def stub_login
  stub_request(:post, "https://idmsa.apple.com/IDMSWebAuth/authenticate").
    with(:body => {"accountPassword"=>"so_secret", "appIdKey"=>"891bd3417a7776362562d2197f89480a8547b108fd934911bcbea0110d07f757", "appleId"=>"spaceship@krausefx.com"},
         :headers => {'Content-Type'=>'application/x-www-form-urlencoded'}).
    to_return(:status => 200, :body => "", :headers => {'Set-Cookie' => "myacinfo=abcdef;"})

  stub_request(:post, "https://idmsa.apple.com/IDMSWebAuth/authenticate").
    with(:body => {"accountPassword"=>"bad-password", "appIdKey"=>"891bd3417a7776362562d2197f89480a8547b108fd934911bcbea0110d07f757", "appleId"=>"bad-username"}).
    to_return(:status => 200, :body => "", :headers => {})

  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/listTeams.action').
    with(:headers => {'Cookie' => 'myacinfo=abcdef;'}).
    to_return(:status => 200, :body => read_fixture_file('listTeams.action.json'), :headers => {'Content-Type' => 'application/json'})
end

def stub_provisioning
  stub_request(:post, "https://developerservices2.apple.com/services/QH65B2/ios/listProvisioningProfiles.action").
    with(:body => "teamId=5A997XSHAA",
         :headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developerservices2.apple.com:443'}).
    to_return(:status => 200, :body => read_fixture_file( "list_provisioning_profiles.plist"), :headers => {})
  stub_request(:get, "https://developer.apple.com/account/ios/profile/profileContentDownload.action?displayId=7EKAHRBJ99").
    with(:headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developer.apple.com:443'}).
    to_return(:status => 200, :body => read_fixture_file( "downloaded_provisioning_profile.mobileprovision"), :headers => {})
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/listProvisioningProfiles.action?teamId=5A997XSHAA").
    with(:headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developer.apple.com:443'}).
    to_return(:status => 200, :body => "", :headers => {csrf: "csrc", csrf_ts: "csrf_ts"})

  # Create Profiles

  # Name already taken
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/createProvisioningProfile.action?teamId=5A997XSHAA").
    with(:body => {"appIdId"=>"R9YNDTPLJX", "certificateIds"=>"C8DL7464RQ", "deviceIds"=>"[RK3285QATH,E687498679,5YTNZ5A9RV,VCD3RH54BK,VA3Z744A8R,T5VFWSCC2Z,GD25LDGN99,XJXGVS46MW,LEL449RZER,WXQ7V239BE,9T5RA84V77,S4227Y42V5,L4378H292Z]", "distributionType"=>"limited", "provisioningProfileName"=>"net.sunapps.106 limited", "returnFullObjects"=>"false"},
         :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'Cookie'=>'myacinfo=abcdef', 'Csrf'=>'csrc', 'Csrf-Ts'=>'', 'Host'=>'developer.apple.com:443'}).
    to_return(:status => 200, :body => read_fixture_file( "create_profile_name_taken.txt"), :headers => {})
  # Name not yet taken
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/createProvisioningProfile.action?teamId=5A997XSHAA").
    with(:body => {"appIdId"=>"R9YNDTPLJX", "certificateIds"=>"C8DL7464RQ", "deviceIds"=>"[RK3285QATH,E687498679,5YTNZ5A9RV,VCD3RH54BK,VA3Z744A8R,T5VFWSCC2Z,GD25LDGN99,XJXGVS46MW,LEL449RZER,WXQ7V239BE,9T5RA84V77,S4227Y42V5,L4378H292Z]", "distributionType"=>"limited", "provisioningProfileName"=>"Not Yet Taken", "returnFullObjects"=>"false"},
         :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'Cookie'=>'myacinfo=abcdef', 'Csrf'=>'csrc', 'Csrf-Ts'=>'', 'Host'=>'developer.apple.com:443'}).
    to_return(:status => 200, :body => read_fixture_file( 'create_profile_success.json'), :headers => {})
end

def stub_devices
  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action').
    with(:body => {:teamId => 'XXXXXXXXXX', :pageSize => "500", :pageNumber => "1", :sort => 'name=asc'}, :headers => {'Cookie' => 'myacinfo=abcdef;'}).
    to_return(:status => 200, :body => read_fixture_file('listDevices.action.json'), :headers => {'Content-Type' => 'application/json'})
end

def stub_certificates
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action").
    with(:body => {"pageNumber"=>"1", "pageSize"=>"500", "sort"=>"certRequestStatusCode=asc", "teamId"=>"XXXXXXXXXX", "types"=>"5QPB9NHCEI,R58UK2EWSO,9RQEK7MSXA,LA30L5BJEU,BKLRAVXMGM,3BQKVH9I2X,Y3B2F3TYSI,3T2ZP62QW8,E5D663CMZW,4APLUP237T"},
         :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'Cookie'=>'myacinfo=abcdef;'}).
    to_return(:status => 200, :body => read_fixture_file('listCertRequests.action.json'), :headers => {'Content-Type' => 'application/json'})

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action").
    with(:body => {"pageNumber"=>"1", "pageSize"=>"500", "sort"=>"certRequestStatusCode=asc", 'teamId' => 'XXXXXXXXXX', 'types' => '5QPB9NHCEI'},
         :headers => {'Cookie'=>'myacinfo=abcdef;'}).
    to_return(:status => 200, :body => read_fixture_file( "list_certificates_filtered.json"), :headers => {'Content-Type' => 'application/json'})
=begin
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action").
    with(:body => {'teamId' => '5A997XSHAA', 'types' => 'R58UK2EWSO'},
         :headers => {'Cookie'=>'myacinfo=abcdef;'}).
    to_return(:status => 200, :body => read_fixture_file( "list_certificates_filtered.json"), :headers => {})
=end
  stub_request(:post, "https://developer.apple.com/account/ios/certificate/certificateContentDownload.action").
    with(:body => {"displayId"=>"XC5PH8DAAA", "type"=>"R58UK2EAAA"},
         :headers => {'Cookie'=>'myacinfo=abcdef;'}).
    to_return(:status => 200, :body => read_fixture_file('aps_development.cer'))
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/submitCertificateRequest.action").
     with(:body => {"appIdId"=>"2HNR359G63", "csrContent"=>read_fixture_file('certificateSigningRequest.certSigningRequest'), "type"=>"BKLRAVXMGM", "teamId"=>"XXXXXXXXXX"},
          :headers => {'Cookie'=>'myacinfo=abcdef;'}).
     to_return(:status => 200, :body => read_fixture_file('submitCertificateRequest.action.json'), :headers => {'Content-Type' => 'application/json'})
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/revokeCertificate.action").
     with(:body => {"certificateId"=>"WHT3M5V55A", "teamId"=>"XXXXXXXXXX", "type"=>"3BQKVH9I2X"},
          :headers => {'Cookie'=>'myacinfo=abcdef;'}).
     to_return(:status => 200, :body => read_fixture_file('revokeCertificate.action.json'), :headers => {'Content-Type' => 'application/json'})

end

def stub_apps
  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/listAppIds.action').
    with(:body => {:teamId => 'XXXXXXXXXX', :pageSize => "500", :pageNumber => "1", :sort => 'name=asc'}, :headers => {'Cookie' => 'myacinfo=abcdef;'}).
    to_return(:status => 200, :body => read_fixture_file('listApps.action.json'), :headers => {'Content-Type' => 'application/json'})

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/addAppId.action").
    with(:body => {"appIdName"=>"Production App", "appIdentifierString"=>"tools.fastlane.spaceship.some-explicit-app", "explicitIdentifier"=>"tools.fastlane.spaceship.some-explicit-app", "gameCenter"=>"on", "inAppPurchase"=>"on", "push"=>"on", "teamId"=>"XXXXXXXXXX", "type"=>"explicit"},
         :headers => {'Cookie'=>'myacinfo=abcdef;'}).
    to_return(:status => 200, :body => read_fixture_file('addAppId.action.explicit.json'), :headers => {'Content-Type' => 'application/json'})

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/addAppId.action").
    with(:body => {"appIdName"=>"Development App", "appIdentifierString"=>"tools.fastlane.spaceship.*", "teamId"=>"XXXXXXXXXX", "type"=>"wildcard", "wildcardIdentifier"=>"tools.fastlane.spaceship.*"},
         :headers => {'Cookie'=>'myacinfo=abcdef;'}).
    to_return(:status => 200, :body => read_fixture_file('addAppId.action.wildcard.json'), :headers => {'Content-Type' => 'application/json'})

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/deleteAppId.action").
    with(:body => {"appIdId"=>"LXD24VUE49", "teamId"=>"XXXXXXXXXX"}).
    to_return(:status => 200, :body => "", :headers => {})
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do

    stub_request(:get, "https://developer.apple.com/devcenter/ios/index.action").
      to_return(:status => 200, :body => read_fixture_file("landing_page.html"), :headers => {})

    stub_login
    stub_provisioning
    stub_devices
    stub_certificates
    stub_apps
  end
end

