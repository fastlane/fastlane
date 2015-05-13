require 'openssl'

module Spaceship
  class Certificates
    include Enumerable
    extend Forwardable

    attr_reader :client
    def_delegators :@certificates, :each, :first, :last

    class Certificate < Struct.new(:id, :name, :status, :created, :expires, :owner_type, :owner_name, :owner_id, :type_display_id, :app)
      def expires_at
        Time.parse(expires)
      end

      def is_push
        #does display_type_id match push?
        [Client::ProfileTypes::Push.development, Client::ProfileTypes::Push.production].include?(type_display_id)
      end
    end

    #these certs are not associated with apps
    class Development < Certificate; end
    class Production < Certificate; end

    #all these certs have apps.
    class PushCertificate < Certificate; end  #abstract class
    class DevelopmentPush < PushCertificate; end
    class ProductionPush < PushCertificate; end
    class WebsitePush < PushCertificate; end
    class VoIPPush < PushCertificate; end
    class Passbook < Certificate; end
    class ApplePay < Certificate; end

    CERTIFICATE_TYPE_IDS = {
      "5QPB9NHCEI" => Development,
      "R58UK2EWSO" => Production,
      "9RQEK7MSXA" => Certificate,
      "LA30L5BJEU" => Certificate,
      "BKLRAVXMGM" => DevelopmentPush,
      "3BQKVH9I2X" => ProductionPush,
      "Y3B2F3TYSI" => Passbook,
      "3T2ZP62QW8" => WebsitePush,
      "E5D663CMZW" => WebsitePush,
      "4APLUP237T" => ApplePay
    }

    def self.factory(attrs)
      values = attrs.values_at('certificateId', 'name', 'statusString', 'dateCreated', 'expirationDate', 'ownerType', 'ownerName', 'ownerId', 'certificateTypeDisplayId')
      klass = CERTIFICATE_TYPE_IDS[attrs['certificateTypeDisplayId']]
      klass ||= Certificate
      klass.new(*values)
    end

    def self.certificate_signing_request
      key = OpenSSL::PKey::RSA.new 2048
      csr = OpenSSL::X509::Request.new
      csr.version = 0
      csr.subject = OpenSSL::X509::Name.new([
        ['CN', 'PEM', OpenSSL::ASN1::UTF8STRING]
      ])
      csr.public_key = key.public_key
      csr.sign(key, OpenSSL::Digest::SHA1.new)
      return [csr, key]
    end

    def initialize(client, types = nil)
      @client = client
      types ||= Client::ProfileTypes.all_profile_types
      @certificates = client.certificates(types).map do |cert|
        self.class.factory(cert)
      end
    end

    def create(klass, csr, bundle_id = nil)
      type = CERTIFICATE_TYPE_IDS.key(klass)
      app_id = nil

      #look up the app_id by the bundle_id
      if bundle_id
        app_id = Spaceship::Apps.new(self.client).find(bundle_id).app_id
      end

      #if this succeeds, we need to save the .cer and the private key in keychain access or wherever they go in linux
      response = client.create_certificate(type, csr.to_pem, app_id)
      #munge the response to make it work for the factory
      response['certificateTypeDisplayId'] = response['certificateType']['certificateTypeDisplayId']
      certificate = self.class.factory(response)
      @certificates << certificate
      certificate
    end

    def find(cert_id)
      @certificates.find do |cert|
        cert.id == cert_id
      end
    end
    alias [] find

    def download(cert_id)
      cert = find(cert_id)
      file = client.download_certificate(cert.id, cert.type_display_id)
      OpenSSL::X509::Certificate.new(file)
    end

    def revoke(cert_id)
      cert = find(cert_id)
      client.revoke_certificate(cert.id, cert.type_display_id)
    end

    #not sure how/when to do this:
    #def activate(cert_id)
    #end
  end
end

