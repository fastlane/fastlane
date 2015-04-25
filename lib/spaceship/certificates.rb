module Spaceship
  class Certificates
    include Spaceship::SharedClient
    include Enumerable

    def initialize
      types = Client::ProfileTypes.all_profile_types
      @certificates = client.certificates(types)
    end

    def each(&block)
      @certificates.each do |cert|
        block.call(cert)
      end
    end

    def find(cert_id)
      each do |cert|
        return cert if cert['certificateId'] == cert_id
      end
    end
    alias [] find

    def file(cert_id)
      cert = find(cert_id)
      file = client.download_certificate(cert['certificateId'], cert['certificateTypeDisplayId'])
      OpenSSL::X509::Certificate.new(file)
    end

    def revoke(cert_id)
      client.revoke(bundle_id)
    end
  end
end

