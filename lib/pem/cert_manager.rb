module PEM
  class CertManager
    # Download the cert, do all kinds of Keychain related things
    def run
      # Keychain (security) documentation: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/security.1.html
      # Old project, which might be helpful: https://github.com/jprichardson/keychain_manager

      Helper.log.info "Refreshing push notification profiles for app '#{PEM.config[:app_identifier]}'"

      dev = PEM::DeveloperCenter.new

      cert_file = dev.fetch_cer_file
      rsa_file = File.join(TMP_FOLDER, 'private_key.key')
      private_key = OpenSSL::PKey::RSA.new(rsa_file)

      certificate_type = (PEM.config[:development] ? 'development' : 'production')

      pem_file = File.join(TMP_FOLDER, "#{certificate_type}_#{PEM.config[:app_identifier]}.pem")

      certificate = OpenSSL::X509::Certificate.new(File.read(cert_file))

      File.open(pem_file, 'w') do |f|
        f.write(certificate.to_pem)
        f.write(private_key.to_pem)
      end

      # Generate p12 file as well
      if PEM.config[:generate_p12]
        p12 = OpenSSL::PKCS12.create(passphrase, certificate_type, private_key, certificate)
        output = "#{certificate_type}.p12"
        File.write(output, p12.to_der)
        puts output.green
      end

      return pem_file, rsa_file
    end
  end
end

