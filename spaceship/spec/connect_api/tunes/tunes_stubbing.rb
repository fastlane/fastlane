class ConnectAPIStubbing
  class Tunes
    class << self
      def read_fixture_file(filename)
        File.read(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'tunes', filename))
      end

      def read_binary_fixture_file(filename)
        File.binread(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'tunes', filename))
      end

      # Necessary, as we're now running this in a different context
      def stub_request(*args)
        WebMock::API.stub_request(*args)
      end

      def stub_app_store_version_release_request
        stub_request(:post, "https://appstoreconnect.apple.com/iris/v1/appStoreVersionReleaseRequests").
          to_return(status: 200, body: read_fixture_file('app_store_version_release_request.json'), headers: { 'Content-Type' => 'application/json' })
      end
    end
  end
end
