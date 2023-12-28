require_relative '../model'
module Spaceship
  class ConnectAPI
    class BuildDelivery
      include Spaceship::ConnectAPI::Model

      attr_accessor :cf_build_version
      attr_accessor :cf_build_short_version_string
      attr_accessor :platform
      attr_accessor :uploaded_date

      attr_mapping({
        "cfBundleVersion" => "cf_build_version",
        "cfBundleShortVersionString" => "cf_build_short_version_string",
        "platform" => "platform",
        "uploadedDate" => "uploaded_date"
      })

      def self.type
        return "buildDeliveries"
      end

      #
      # API
      #

      def self.all(client: nil, app_id: nil, version: nil, build_number: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_build_deliveries(
          app_id: app_id,
          filter: { cfBundleShortVersionString: version, cfBundleVersion: build_number },
          limit: 1
        ).all_pages
        return resps.flat_map(&:to_models)
      end
    end
  end
end
