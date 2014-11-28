module PEM
  class SigningRequest
    def self.get_path
      self.generate
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
      File.write(File.join(TMP_FOLDER, 'private_key.key'), @key)

      Helper.log.info "Successfully generated .certSigningRequest at path '#{path}'"
      return path
    end
  end
end