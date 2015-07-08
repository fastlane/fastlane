require 'openssl'

module Cert
  class SigningRequest
    def self.get_path
      return Cert.config[:signing_request_path] if Cert.config[:signing_request_path]
      
      self.generate
    end

    def self.generate
      Helper.log.info "Creating a signing certificate for you.".green
      key = OpenSSL::PKey::RSA.new 2048
 
      # Generate CSR
      csr = OpenSSL::X509::Request.new
      csr.version = 0 
      csr.subject = OpenSSL::X509::Name.new([
        ['CN', "PEM", OpenSSL::ASN1::UTF8STRING]
      ])
      csr.public_key = key.public_key
      csr.sign key, OpenSSL::Digest::SHA1.new
       
      path = File.join(TMP_FOLDER, 'CertCertificateSigningRequest.certSigningRequest')
      private_key_path = File.join(TMP_FOLDER, 'private_key.p12')
      File.write(path, csr.to_pem)
      File.write(private_key_path, key)

      # Import the private key into the Keychain
      puts `chmod 600 '#{private_key_path}'` # otherwise we're not allowed to import the private key
      KeychainImporter.import_file(private_key_path)

      Helper.log.info "Successfully generated .certSigningRequest at path '#{path}'".green
      return path
    end
  end
end