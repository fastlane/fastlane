require_relative 'mock_servers/test_flight_server'
require_relative 'mock_servers/developer_portal_server'

RSpec.configure do |config|
  config.include(WebMock::API)

  config.before do
    stub_request(:any, %r(itunesconnect.apple.com/testflight/v2)).to_rack(MockAPI::TestFlightServer)
    stub_request(:any, %r(developer.apple.com/services-account/QH65B2/account/auth/key)).to_rack(MockAPI::DeveloperPortalServer)
    stub_request(:any, %r(developer.apple.com/services-account/QH65B2/account/ios/identifiers/.*OMC(s){0,1}\.action)).to_rack(MockAPI::DeveloperPortalServer)
  end

  config.after do
    MockAPI::TestFlightServer.instance_variable_set(:@routes, {})
    MockAPI::DeveloperPortalServer.instance_variable_set(:@routes, {})
  end
end
