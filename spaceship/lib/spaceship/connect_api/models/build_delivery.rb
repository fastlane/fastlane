require_relative './model'
module Spaceship
  module ConnectAPI
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

      def self.all(app_id: nil, version: nil, build_number: nil)
        return client.page do
          client.get_build_deliveries(
            filter: { app: app_id, cfBundleShortVersionString: version, cfBundleVersion: build_number },
            limit: 1
          )
        end.map do |resp|
          Spaceship::ConnectAPI::BuildDelivery.parse(resp)
        end.flatten
      end
    end
  end
end
