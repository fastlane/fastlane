class ConnectAPIStubbing
  class Users
    class << self
      def read_fixture_file(filename)
        File.read(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'users', filename))
      end

      def read_binary_fixture_file(filename)
        File.binread(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'users', filename))
      end

      # Necessary, as we're now running this in a different context
      def stub_request(*args)
        WebMock::API.stub_request(*args)
      end

      def stub_users
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/users").
          to_return(status: 200, body: read_fixture_file('users.json'), headers: { 'Content-Type' => 'application/json' })
      end
    end
  end
end
