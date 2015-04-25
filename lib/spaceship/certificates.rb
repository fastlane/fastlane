module Spaceship
  class Certificates
    include Spaceship::SharedClient
    include Enumerable

    def initialize
      types = Client::ProfileTypes.all_profile_types
      cert_map = client.certificates(types).map{|cert| [cert['certificateId'], cert] }

      @certificates = Hash[cert_map]
    end

    def each(&block)
      @certificates.each do |bundle_id, cert|
        block.call(cert, bundle_id)
      end
    end

    def file(cert_id)
      cert = @certificates[cert_id]
      file = client.download_certificate(cert['certificateId'], cert['certificateTypeDisplayId'])
      OpenSSL::X509::Certificate.new(file)
    end

    def revoke(cert_id)
      client.revoke(bundle_id)
    end
  end
end

