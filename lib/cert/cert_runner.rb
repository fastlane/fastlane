module Cert
  class CertRunner
    def launch
      run

      installed = FastlaneCore::CertChecker.is_installed?ENV["CER_FILE_PATH"]
      raise "Could not find the newly generated certificate installed" unless installed
    end

    def run
      Helper.log.info "Starting login"
      Spaceship.login(Cert.config[:username], nil)
      Spaceship.select_team
      Helper.log.info "Successfully logged in"

      if find_existing_cert
        return # success
      else
        if create_certificate # no certificate here, creating a new one
          return # success
        else
          raise "Something went wrong when trying to create a new certificate..."
        end
      end
    end

    def find_existing_cert
      certificates.each do |certificate|
        path = store_certificate(certificate)

        if FastlaneCore::CertChecker.is_installed?path
          # This certificate is installed on the local machine
          ENV["CER_CERTIFICATE_ID"] = certificate.id
          ENV["CER_FILE_PATH"] = path

          Helper.log.info "Found the certificate #{certificate.id} (#{certificate.name}) which is installed on the local machine. Using this one.".green

          return path
        end
      end

      Helper.log.info "Couldn't find an existing certificate... creating a new one"
      return nil
    end

    # All certificates of this type
    def certificates
      certificate_type.all
    end

    # The kind of certificate we're interested in
    def certificate_type
      cert_type = Spaceship.certificate.production
      cert_type = Spaceship.certificate.development if Cert.config[:development]
      cert_type = Spaceship.certificate.in_house if Spaceship.client.in_house?

      cert_type
    end

    def create_certificate
      # Create a new certificate signing request
      csr, pkey = Spaceship.certificate.create_certificate_signing_request

      # Use the signing request to create a new distribution certificate
      begin
        certificate = certificate_type.create!(csr: csr)
      rescue => ex
        Helper.log.error "Could not create another certificate, reached the maximum number of available certificates.".red
        raise ex
      end

      # Store all that onto the filesystem
      request_path = File.join(Cert.config[:output_path], 'CertCertificateSigningRequest.certSigningRequest')
      File.write(request_path, csr.to_pem)
      private_key_path = File.join(Cert.config[:output_path], 'private_key.p12')
      File.write(private_key_path, pkey)
      cert_path = store_certificate(certificate)

      # Import all the things into the Keychain
      KeychainImporter.import_file(private_key_path)
      KeychainImporter.import_file(cert_path)

      # Environment variables for the fastlane action
      ENV["CER_CERTIFICATE_ID"] = certificate.id
      ENV["CER_FILE_PATH"] = cert_path

      Helper.log.info "Successfully generated #{certificate.id} which was imported to the local machine.".green

      return cert_path
    end

    def store_certificate(certificate)
      path = File.join(Cert.config[:output_path], "#{certificate.id}.cer")
      raw_data = certificate.download_raw
      File.write(path, raw_data)
      return path
    end
  end
end
