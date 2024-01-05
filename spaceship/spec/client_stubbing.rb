class ClientStubbing
  class << self
    def client_read_fixture_file(filename)
      File.read(File.join('spaceship', 'spec', 'fixtures', filename))
    end

    # Necessary, as we're now running this in a different context
    def stub_request(*args)
      WebMock::API.stub_request(*args)
    end

    def stub_connection_timeout_302
      stub_request(:get, "http://example.com/").
        to_return(status: 200, body: client_read_fixture_file('302.html'), headers: {})
    end
  end
end
