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


      # Create a new code signing request that can be used to
      # generate a new certificate
      # @example
      #  Create a new certificate signing request
      #  csr, pkey = Spaceship.certificate.create_certificate_signing_request
      #
      #  # Use the signing request to create a new distribution certificate
      #  Spaceship.certificate.production.create!(csr: csr)
      def self.create_certificate_signing_request
        key = OpenSSL::PKey::RSA.new(2048)
        csr = OpenSSL::X509::Request.new
        csr.version = 0
        csr.subject = OpenSSL::X509::Name.new([
                                                ['CN', 'PEM', OpenSSL::ASN1::UTF8STRING]
                                              ])
        csr.public_key = key.public_key
        csr.sign(key, OpenSSL::Digest::SHA1.new)
        return [csr, key]
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_certificates(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.create(certificate_type: nil, csr_content: nil)
        attributes = {
          certificateType: certificate_type,
          csrContent: csr_content
        }
        resp = Spaceship::ConnectAPI.post_certificate(attributes: attributes)
        return resp.to_models.first
      end

      def self.get(certificate_id: nil, includes: nil)
        resp = Spaceship::ConnectAPI.get_certificate(certificate_id: certificate_id, includes: includes)
        return resp.to_models.first
      end
    end
  end
end
