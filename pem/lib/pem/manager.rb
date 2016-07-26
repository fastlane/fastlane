require 'pathname'
require 'spaceship'

module PEM
  # Creates the push profile and stores it in the correct location
  class Manager
    class << self
      PEM_CERTIFICATE_DISPLAY = {
          Spaceship::Portal::App::MAC => "Push Certificate",
          Spaceship::Portal::App::IOS => "Push Certificate",
          Spaceship::Portal::App::PASS => "Pass Certificate",
          Spaceship::Portal::App::WEB => "Website Push Certificate",
          Spaceship::Portal::App::MERCHANT => "Apple Pay Certificate"
      }.freeze

      def start
        FastlaneCore::PrintTable.print_values(config: PEM.config, hide_keys: [:new_profile], title: "Summary for PEM #{PEM::VERSION}")
        login

        app = Spaceship.app.find_by_platform(PEM.config[:app_identifier], platform: PEM.config[:platform])
        raise UI.error "Could not find an app with the identifier #{PEM.config[:app_identifier]}" if app.nil?

        PEM.config[:platform] = app.platform if PEM.config[:platform].nil?

        existing_certificate = certificate.all_by_platform(platform: PEM.config[:platform]).detect do |c|
          c.name == PEM.config[:app_identifier]
        end

        if existing_certificate
          remaining_days = (existing_certificate.expires - Time.now) / 60 / 60 / 24
          UI.message "Existing #{PEM_CERTIFICATE_DISPLAY[PEM.config[:platform]]} profile '#{existing_certificate.owner_name}' is valid for #{remaining_days.round} more days."
          if remaining_days > 30
            if PEM.config[:force]
              UI.success "You already have an existing #{PEM_CERTIFICATE_DISPLAY[PEM.config[:platform]]}, but a new one will be created since the --force option has been set."
            else
              UI.success "You already have a  #{PEM_CERTIFICATE_DISPLAY[PEM.config[:platform]]}, which is active for more than 30 more days. No need to create a new one"
              UI.success "If you still want to create a new one, use the --force option when running PEM."
              return false
            end
          end
        end
        return create_certificate
      end

      def login
        UI.message "Starting login with user '#{PEM.config[:username]}'"
        Spaceship.login(PEM.config[:username], nil)
        Spaceship.client.select_team
        UI.message "Successfully logged in"
      end

      # rubocop:disable Metrics/AbcSize
      def create_certificate(app: nil)
        UI.important "Creating a new #{PEM_CERTIFICATE_DISPLAY[PEM.config[:platform]]} for app '#{PEM.config[:app_identifier]}'."

        csr, pkey = Spaceship.certificate.create_certificate_signing_request

        begin
          cert = certificate.create!(csr: csr, bundle_id: PEM.config[:app_identifier])
        rescue => ex
          if ex.to_s.include? "You already have a current"
            # That's the most common failure probably
            UI.message ex.to_s
            UI.user_error!("You already have 2 active #{PEM_CERTIFICATE_DISPLAY[PEM.config[:platform]]}s for this application/environment. You'll need to revoke an old certificate to make room for a new one")
          else
            raise ex
          end
        end

        x509_certificate = cert.download
        certificate_type = (PEM.config[:development] ? 'development' : 'production')
        filename_base = PEM.config[:pem_name] || "#{certificate_type}_#{PEM.config[:app_identifier]}"
        filename_base = File.basename(filename_base, ".pem") # strip off the .pem if it was provided.

        if PEM.config[:save_private_key]
          private_key_path = File.join(PEM.config[:output_path], "#{filename_base}.pkey")
          File.write(private_key_path, pkey.to_pem)
          UI.message("Private key: ".green + Pathname.new(private_key_path).realpath.to_s)
        end

        if PEM.config[:generate_p12]
          output_path = PEM.config[:output_path]
          FileUtils.mkdir_p(File.expand_path(output_path))
          p12_cert_path = File.join(output_path, "#{filename_base}.p12")
          p12 = OpenSSL::PKCS12.create(PEM.config[:p12_password], certificate_type, pkey, x509_certificate)
          File.write(p12_cert_path, p12.to_der)
          UI.message("p12 certificate: ".green + Pathname.new(p12_cert_path).realpath.to_s)
        end

        x509_cert_path = File.join(PEM.config[:output_path], "#{filename_base}.pem")
        File.write(x509_cert_path, x509_certificate.to_pem + pkey.to_pem)
        UI.message("PEM: ".green + Pathname.new(x509_cert_path).realpath.to_s)
        return x509_cert_path
      end
      # rubocop:enable Metrics/AbcSize

      def certificate
        if PEM.config[:platform] == Spaceship::Portal::App::IOS
          if PEM.config[:development]
            Spaceship.certificate.development_push
          else
            Spaceship.certificate.production_push
          end
        elsif PEM.config[:platform] == Spaceship::Portal::App::MAC
          if PEM.config[:development]
            Spaceship.certificate.mac_development_push
          else
            Spaceship.certificate.mac_production_push
          end
        elsif PEM.config[:platform] == Spaceship::Portal::App::WEB
          Spaceship.certificate.website_push
        elsif PEM.config[:platform] == Spaceship::Portal::App::MERCHANT
          Spaceship.certificate.apple_pay
        elsif PEM.config[:platform] == Spaceship::Portal::App::PASS
          Spaceship.certificate.passbook
        end
      end
    end
  end
end
