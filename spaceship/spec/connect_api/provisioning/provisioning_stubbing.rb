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

      def stub_patch_bundle_id_capability
        # APP_ATTEST
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => false, "settings" => [] }, "relationships" => { "capability" => { "data" => { "type" => "capabilities", "id" => "APP_ATTEST" } } } }] } } } }).
          to_return(status: 200)
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => true, "settings" => [] }, "relationships" => { "capability" => { "data" => { "type" => "capabilities", "id" => "APP_ATTEST" } } } }] } } } }).
          to_return(status: 200)

        # ACCESS_WIFI
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => false, "settings" => [] }, "relationships" => { "capability" => { "data" => { "type" => "capabilities", "id" => "ACCESS_WIFI_INFORMATION" } } } }] } } } }).
          to_return(status: 200)
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => true, "settings" => [] }, "relationships" => { "capability" => { "data" => { "type" => "capabilities", "id" => "ACCESS_WIFI_INFORMATION" } } } }] } } } }).
          to_return(status: 200)

        # DATA_PROTECTION
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => true, "settings" => [{ "key" => "DATA_PROTECTION_PERMISSION_LEVEL", "options" => [{ "key" => "COMPLETE_PROTECTION" }] }] }, "relationships" => { "capability" =>
          { "data" => { "type" => "capabilities", "id" => "DATA_PROTECTION" } } } }] } } } }).to_return(status: 200)
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => true, "settings" => [{ "key" => "DATA_PROTECTION_PERMISSION_LEVEL", "options" => [{ "key" => "PROTECTED_UNLESS_OPEN" }] }] }, "relationships" => { "capability" =>
          { "data" => { "type" => "capabilities", "id" => "DATA_PROTECTION" } } } }] } } } }).to_return(status: 200)
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => true, "settings" => [{ "key" => "DATA_PROTECTION_PERMISSION_LEVEL", "options" => [{ "key" => "PROTECTED_UNTIL_FIRST_USER_AUTH" }] }] }, "relationships" => { "capability" =>
          { "data" => { "type" => "capabilities", "id" => "DATA_PROTECTION" } } } }] } } } }).to_return(status: 200)
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => false, "settings" => [] }, "relationships" => { "capability" => { "data" => { "type" => "capabilities", "id" => "DATA_PROTECTION" } } } }] } } } }).
          to_return(status: 200)

        # ICLOUD
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => true, "settings" => [{ "key" => "ICLOUD_VERSION", "options" => [{ "key" => "XCODE_5" }] }] }, "relationships" => { "capability" => { "data" => { "type" => "capabilities", "id" => "ICLOUD" } } } }] } } } }).
          to_return(status: 200)
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => true, "settings" => [{ "key" => "ICLOUD_VERSION", "options" => [{ "key" => "XCODE_6" }] }] }, "relationships" => { "capability" => { "data" => { "type" => "capabilities", "id" => "ICLOUD" } } } }] } } } }).
          to_return(status: 200)
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/ABCD1234").
          with(body: { "data" => { "type" => "bundleIds", "id" => "ABCD1234", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "SEEDID", "teamId" => "XXXXXXXXXX" },
  "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => false, "settings" => [] }, "relationships" => { "capability" => { "data" => { "type" => "capabilities", "id" => "ICLOUD" } } } }] } } } }).
          to_return(status: 200)
      end

      def stub_bundle_id
        stub_request(:post, "https://developer.apple.com/services-account/v1/bundleIds/123456789").
          to_return(status: 200, body: read_fixture_file('bundle_id.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      def stub_available_bundle_id_capabilities
        stub_request(:post, "https://developer.apple.com/services-account/v1/capabilities").
          to_return(status: 200, body: read_fixture_file('capabilities.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      def stub_certificates
        stub_request(:post, "https://developer.apple.com/services-account/v1/certificates").
          to_return(status: 200, body: read_fixture_file('certificates.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      def stub_devices
        stub_request(:post, "https://developer.apple.com/services-account/v1/devices").
          to_return(status: 200, body: read_fixture_file('devices.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:patch, "https://developer.apple.com/services-account/v1/devices/13371337").
          to_return(status: 200, body: read_fixture_file('device_enable.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:patch, "https://developer.apple.com/services-account/v1/devices/123456789").
          to_return(status: 200, body: read_fixture_file('device_disable.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })

        stub_request(:patch, "https://developer.apple.com/services-account/v1/devices/987654321").
          to_return(status: 200, body: read_fixture_file('device_rename.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      def stub_profiles
        stub_request(:post, "https://developer.apple.com/services-account/v1/profiles").
          to_return(status: 200, body: read_fixture_file('profiles.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end
    end
  end
end
