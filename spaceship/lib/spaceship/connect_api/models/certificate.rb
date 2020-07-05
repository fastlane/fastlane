require_relative '../model'
module Spaceship
  class ConnectAPI
    class Certificate
      include Spaceship::ConnectAPI::Model

      attr_accessor :certificate_content
      attr_accessor :display_name
      attr_accessor :name
      attr_accessor :platform
      attr_accessor :serial_number
      attr_accessor :certificate_type
      attr_accessor :requester_email
      attr_accessor :requester_first_name
      attr_accessor :requester_last_name

      attr_mapping({
        "certificateContent" => "certificate_content",
        "displayName" => "display_name",
        "expirationDate" => "expiration_date",
        "name" => "name",
        "platform" => "platform",
        "serialNumber" => "serial_number",
        "certificateType" => "certificate_type",
        "requesterEmail" => "requester_email",
        "requesterFirstName" => "requester_first_name",
        "requesterLastName" => "requester_last_name"
      })

      module CertificateType
        DEVELOPMENT = "DEVELOPMENT"
        DISTRIBUTION = "DISTRIBUTION"
        IOS_DEVELOPMENT = "IOS_DEVELOPMENT"
        IOS_DISTRIBUTION = "IOS_DISTRIBUTION"
        MAC_APP_DISTRIBUTION = "MAC_APP_DISTRIBUTION"
        MAC_INSTALLER_DISTRIBUTION = "MAC_INSTALLER_DISTRIBUTION"
        MAC_APP_DEVELOPMENT = "MAC_APP_DEVELOPMENT"
        DEVELOPER_ID_KEXT = "DEVELOPER_ID_KEXT"
        DEVELOPER_ID_APPLICATION = "DEVELOPER_ID_APPLICATION"
      end

      def self.type
        return "certificates"
      end

      def valid?
        Time.parse(expiration_date) > Time.now
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_certificates(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end
    end
  end
end
