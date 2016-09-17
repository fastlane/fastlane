require 'webmock/rspec'

def client_read_fixture_file(filename)
  File.read(File.join('spec', 'fixtures', filename))
end

def stub_connection_timeout_302
  stub_request(:get, "http://example.com/").
    to_return(status: 200, body: client_read_fixture_file('302.html'), headers: {})
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
  end
end
