require_relative 'mock_servers/test_flight_server'

RSpec.configure do |config|
  config.include WebMock::API

  config.before do
    stub_request(:any, %r(itunesconnect.apple.com/testflight/v2)).to_rack(MockAPI::TestFlightServer)
  end

  config.after do
    # we do not want stale routes from previous tests
    # TODO[snatchev]: this doesn't quite work. It clears the routes, but for some reason newly defined routes don't show up.
    # MockAPI::TestFlightServer.set :routes, {}
  end
end
