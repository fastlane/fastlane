module PEM
  class SigningRequest
    def self.get_path
      return ENV["PEM_CERT_SIGNING_REQUEST"] if (ENV["PEM_CERT_SIGNING_REQUEST"] and File.exists?(ENV["PEM_CERT_SIGNING_REQUEST"]))

      # Check if there is one in the current directory
      files = Dir["./*.certSigningRequest"]
      if files.count == 1
        Helper.log.info "Found a .certSigningRequest at the current folder. Using that."
        return files.first
      end

      return self.generate
    end

    def self.generate
      Helper.log.info "Couldn't find a signing certificate in the current folder. Creating one for you now.".green
      @key = OpenSSL::PKey::RSA.new 2048
 
      # Generate CSR
      csr = OpenSSL::X509::Request.new
      csr.version = 0 
      csr.subject = OpenSSL::X509::Name.new([
        ['CN', "PEM", OpenSSL::ASN1::UTF8STRING]
      ])
      csr.public_key = @key.public_key
      csr.sign @key, OpenSSL::Digest::SHA1.new
       
      path = File.join(TMP_FOLDER, 'PEMCertificateSigningRequest.certSigningRequest')
      File.write(path, csr.to_pem)
      Helper.log.info "Successfully generated .certSigningRequest at path '#{path}'"
      return path
    end
  end
end