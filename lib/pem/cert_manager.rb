module PEM
  class CertManager

    attr_accessor :rsa_file, :cert_file, :pem_file, :certificate_type, :passphrase

    # Download the cert, do all kinds of Keychain related things
    def run
      # Keychain (security) documentation: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/security.1.html
      # Old project, which might be helpful: https://github.com/jprichardson/keychain_manager

      Helper.log.info "Refreshing push notification profiles for app '#{PEM.config[:app_identifier]}'"

      dev = PEM::DeveloperCenter.new

      self.cert_file = dev.fetch_cer_file
      if self.cert_file
        self.rsa_file = File.join(TMP_FOLDER, 'private_key.key')
        self.certificate_type = (PEM.config[:development] ? 'development' : 'production')
        self.pem_file = File.join(TMP_FOLDER, "#{certificate_type}_#{PEM.config[:app_identifier]}.pem")
        self.passphrase = PEM.config[:p12_password] || ''

        File.write(pem_file, pem_certificate)

        # Generate p12 file as well
        if PEM.config[:generate_p12]
          output = "#{certificate_type}_#{PEM.config[:app_identifier]}.p12"
          File.write(output, p12_certificate.to_der)
          puts output.green
        end

        return pem_file, rsa_file
      else
        return nil, nil
      end
    end

    def private_key
      OpenSSL::PKey::RSA.new(File.read(rsa_file))
    end

    def x509_certificate
      OpenSSL::X509::Certificate.new(File.read(cert_file))
    end

    def p12_certificate
      OpenSSL::PKCS12.create(passphrase, certificate_type, private_key, x509_certificate)
    end

    def pem_certificate
      x509_certificate.to_pem + private_key.to_pem
    end
  end
end

