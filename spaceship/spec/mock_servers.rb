require_relative 'mock_servers/test_flight_server'

RSpec.configure do |config|
  config.include WebMock::API

  config.before(:each) do
    stub_request(:any, %r(itunesconnect.apple.com/testflight/v2)).to_rack(MockAPI::TestFlightServer)
  end
end
