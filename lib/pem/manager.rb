require 'pathname'
require 'spaceship'

module PEM
  # Creates the push profile and stores it in the correct location
  class Manager

    def self.start
      password_manager = CredentialsManager::PasswordManager.shared_manager
      Spaceship.login(password_manager.username, password_manager.password)
      Spaceship.client.select_team

      existing_certificate = Spaceship.certificate.all.detect { |c| c.name == PEM.config[:app_identifier] }

      if existing_certificate
        remaining_days = (existing_certificate.expires - Time.now) / 60 / 60 / 24
        Helper.log.info "Existing push notification profile '#{existing_certificate.owner_name}' is valid for #{remaining_days.round} more days."
        if remaining_days > 30
          if PEM.config[:force]
            Helper.log.info "You already have an existing push certificate, but a new one will be created since the --force option has been set.".green
          else
            Helper.log.info "You already have a push certificate, which is active for more than 30 more days. No need to create a new one".green
            Helper.log.info "If you still want to create a new one, use the --force option when running PEM.".green
            return false
          end
        end
      end

      Helper.log.warn "Creating a new push certificate for app '#{PEM.config[:app_identifier]}'."

      csr, pkey = Spaceship.certificate.create_certificate_signing_request

      begin
        if PEM.config[:development]
          cert = Spaceship.certificate.development_push.create!(csr: csr, bundle_id: PEM.config[:app_identifier])
        else
          cert = Spaceship.certificate.production_push.create!(csr: csr, bundle_id: PEM.config[:app_identifier])
        end
      rescue => ex
        if ex.to_s.include?"You already have a current"
          # That's the most common failure probably
          Helper.log.info ex.to_s
          Helper.log.error "You already have 2 active push profiles for this application/environment.".red
          Helper.log.error "You'll need to revoke an old certificate to make room for a new one".red
        else
          raise ex
        end
      end

      x509_certificate = cert.download
      certificate_type = (PEM.config[:development] ? 'development' : 'production')
      filename_base = PEM.config[:pem_name] || "#{certificate_type}_#{PEM.config[:app_identifier]}"
      filename_base = File.basename(filename_base, ".pem") # strip off the .pem if it was provided.

      if PEM.config[:save_private_key]
        file = File.new("#{filename_base}.pkey",'w')
        file.write(pkey.to_pem)
        file.close
        Helper.log.info "Private key: ".green + Pathname.new(file).realpath.to_s
      end

      if PEM.config[:generate_p12]
        certificate_type = (PEM.config[:development] ? 'development' : 'production')
        p12 = OpenSSL::PKCS12.create(PEM.config[:p12_password], certificate_type, pkey, x509_certificate)
        file = File.new("#{filename_base}.p12", 'wb')
        file.write(p12.to_der)
        file.close
        Helper.log.info "p12 certificate: ".green + Pathname.new(file).realpath.to_s
      end

      file = File.new("#{filename_base}.pem", 'w')
      file.write(x509_certificate.to_pem + pkey.to_pem)
      file.close
      Helper.log.info "PEM: ".green + Pathname.new(file).realpath.to_s
      return file
    end
  end
end
