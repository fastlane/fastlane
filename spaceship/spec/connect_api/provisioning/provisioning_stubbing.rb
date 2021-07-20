class ConnectAPIStubbing
  class Provisioning
    class << self
      def read_fixture_file(filename)
        File.read(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'provisioning', filename))
      end

      def read_binary_fixture_file(filename)
        File.binread(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'provisioning', filename))
      end

      # Necessary, as we're now running this in a different context
      def stub_request(*args)
        WebMock::API.stub_request(*args)
      end

      def stub_bundle_ids
        stub_request(:post, "https://developer.apple.com/services-account/v1/bundleIds").
          to_return(status: 200, body: read_fixture_file('bundle_ids.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      def stub_bundle_id
        stub_request(:post, "https://developer.apple.com/services-account/v1/bundleIds/123456789").
          to_return(status: 200, body: read_fixture_file('bundle_id.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      def stub_certificates
        stub_request(:post, "https://developer.apple.com/services-account/v1/certificates").
          to_return(status: 200, body: read_fixture_file('certificates.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      def stub_devices
        stub_request(:post, "https://developer.apple.com/services-account/v1/devices").
          to_return(status: 200, body: read_fixture_file('devices.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      def stub_profiles
        stub_request(:post, "https://developer.apple.com/services-account/v1/profiles").
          to_return(status: 200, body: read_fixture_file('profiles.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end
    end
  end
end
