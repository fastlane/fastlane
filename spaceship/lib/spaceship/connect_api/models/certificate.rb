require_relative '../../connect_api'

require 'openssl'

module Spaceship
  class ConnectAPI
    class Certificate
      include Spaceship::ConnectAPI::Model

      attr_accessor :certificate_content
      attr_accessor :display_name
      attr_accessor :expiration_date
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
        DEVELOPER_ID_APPLICATION_G2 = "DEVELOPER_ID_APPLICATION_G2"

        # As of 2021-11-09, this is only available with Apple ID auth
        DEVELOPER_ID_INSTALLER = "DEVELOPER_ID_INSTALLER"
      end

      def self.type
        return "certificates"
      end

      def valid?
        return false if expiration_date.nil? || expiration_date.empty?
        Time.parse(expiration_date) > Time.now
      end

      # Create a new cert signing request that can be used to
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
        csr.sign(key, OpenSSL::Digest::SHA256.new)
        return [csr, key]
      end

      #
      # API
      #

      # Certificate types not supported by the App Store Connect API.
      # https://api.appstoreconnect.apple.com/v1/certificates?filter[certificateType]=DEVELOPER_ID_APPLICATION_G2
      # Radar: FB21181137.
      UNSUPPORTED_CERTIFICATE_TYPE_FILTERS = [
        CertificateType::DEVELOPER_ID_APPLICATION_G2
      ]

      def self.all(client: nil, filter: {}, includes: nil, fields: nil, limit: Spaceship::ConnectAPI::MAX_OBJECTS_PER_PAGE_LIMIT, sort: nil)
        client ||= Spaceship::ConnectAPI

        new_filter = filter.dup

        has_unsupported_cert_types_filter = filter[:certificateType] && UNSUPPORTED_CERTIFICATE_TYPE_FILTERS.any? { |type| filter[:certificateType].include?(type) }

        # If the filter contains unsupported certificate types:
        # - remove the certificateType filter completely and fetch all certificates
        # - filter fetched certificates later by the given certificate types
        if has_unsupported_cert_types_filter
          new_filter[:certificateType] = nil
        end
        new_filter.compact!

        resps = client.get_certificates(filter: new_filter, includes: includes, fields: fields, limit: limit, sort: sort).all_pages

        certs = resps.flat_map(&:to_models)

        if has_unsupported_cert_types_filter
          # Filter fetched certificates by the given certificate types if we encountered unsupported certificate types in the filter previously.
          certs.select! do |cert|
            filter[:certificateType].include?(cert.certificate_type)
          end
        end

        return certs
      end

      def self.create(client: nil, certificate_type: nil, csr_content: nil)
        client ||= Spaceship::ConnectAPI
        attributes = {
          certificateType: certificate_type,
          csrContent: csr_content
        }
        resp = client.post_certificate(attributes: attributes)
        return resp.to_models.first
      end

      def self.get(client: nil, certificate_id: nil, includes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_certificate(certificate_id: certificate_id, includes: includes)
        return resp.to_models.first
      end

      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_certificate(certificate_id: id)
      end
    end
  end
end
