require_relative 'mock_servers/test_flight_server'

RSpec.configure do |config|
  config.include WebMock::API

  config.before do
    stub_request(:any, %r(itunesconnect.apple.com/testflight/v2)).to_rack(MockAPI::TestFlightServer)
  end

  config.after do
    # TODO[snatchev]: There might be a better way to reset the routes. Unforuntately, `Sinatra::Base.reset!` resets too much.
    MockAPI::TestFlightServer.instance_variable_set(:@routes, {})
  end
end
