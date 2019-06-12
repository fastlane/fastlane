require 'spaceship/connect_api/provisioning/client'

module Spaceship
  class ConnectAPI
    module Provisioning
      #
      # bundleIds
      #

      def get_bundle_ids(filter: {}, includes: nil, limit: nil, sort: nil)
        params = client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        client.get("bundleIds", params)
      end

      #
      # certificates
      #

      def get_certificates(filter: {}, includes: nil, limit: nil, sort: nil)
        params = client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        client.get("certificates", params)
      end

      #
      # devices
      #

      def get_devices(filter: {}, includes: nil, limit: nil, sort: nil)
        params = client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        client.get("devices", params)
      end

      #
      # profiles
      #

      def get_profiles(filter: {}, includes: nil, limit: nil, sort: nil)
        params = client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        client.get("profiles", params)
      end

      private

      def client
        Spaceship::ConnectAPI::Provisioning::Client.instance
      end
    end
  end
end
