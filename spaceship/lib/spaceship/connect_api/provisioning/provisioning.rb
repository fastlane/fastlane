require 'spaceship/connect_api/provisioning/client'

module Spaceship
  class ConnectAPI
    module Provisioning
      #
      # bundleIds
      #

      def get_bundle_ids(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("bundleIds", params)
      end

      def get_bundle_id(bundle_id_id: {}, includes: nil)
        params = Client.instance.build_params(filter: nil, includes: includes, limit: nil, sort: nil)
        Client.instance.get("bundleIds/#{bundle_id_id}", params)
      end

      #
      # certificates
      #

      def get_certificates(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("certificates", params)
      end

      #
      # devices
      #

      def get_devices(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("devices", params)
      end

      #
      # profiles
      #

      def get_profiles(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("profiles", params)
      end
    end
  end
end
