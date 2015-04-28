module Spaceship
  class Certificates
    include Spaceship::SharedClient
    include Enumerable
    extend Forwardable

    def_delegators :@certificates, :each, :first, :last

    Certificate = Struct.new(:id, :name, :status, :created, :expires, :owner_type, :owner_name, :owner_id, :type_display_id) do
      def expires_at
        Time.parse(expires)
      end

      def is_push
        #does display_type_id match push?
        [Client::ProfileTypes::Push.development, Client::ProfileTypes::Push.production].include?(type_display_id)
      end
    end

    def initialize(types = nil)
      types ||= Client::ProfileTypes.all_profile_types
      @certificates = client.certificates(types).map do |cert|
        values = cert.values_at('certificateId', 'name', 'statusString', 'dateCreated', 'expirationDate', 'ownerType', 'ownerName', 'ownerId', 'certificateTypeDisplayId')
        Certificate.new(*values)
      end
    end

    def find(cert_id)
      @certificates.find do |cert|
        cert.id == cert_id
      end
    end
    alias [] find

    def file(cert_id)
      cert = find(cert_id)
      file = client.download_certificate(cert.id, cert.type_display_id)
      OpenSSL::X509::Certificate.new(file)
    end

    def revoke(cert_id)
      client.revoke(bundle_id)
    end

    #not sure how/when to do this:
    #def activate(cert_id)
    #end
  end
end

