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
        "uploadedDate" => "uploaded_date",
      })

      def self.type
        return "buildDeliveries"
      end
    end
  end
end
