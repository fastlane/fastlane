require 'pathname'

require 'spaceship'
require 'fastlane_core/print_table'
require_relative 'module'

module PEM
  # Creates the push profile and stores it in the correct location
  class Manager
    class << self
      def start
        FastlaneCore::PrintTable.print_values(config: PEM.config, hide_keys: [:new_profile], title: "Summary for PEM #{Fastlane::VERSION}")
        login

        existing_certificate = certificate_sorted.detect do |c|
          c.owner_name == PEM.config[:app_identifier]
        end

        if existing_certificate
          remaining_days = (existing_certificate.expires - Time.now) / 60 / 60 / 24

          display_platform = ''
          unless PEM.config[:website_push]
            display_platform = "#{PEM.config[:platform]} "
          end

          UI.message("Existing #{display_platform}push notification profile for '#{existing_certificate.owner_name}' is valid for #{remaining_days.round} more days.")
          if remaining_days > PEM.config[:active_days_limit]
            if PEM.config[:force]
              UI.success("You already have an existing push certificate, but a new one will be created since the --force option has been set.")
            else
              UI.success("You already have a push certificate, which is active for more than #{PEM.config[:active_days_limit]} more days. No need to create a new one")
              UI.success("If you still want to create a new one, use the --force option when running PEM.")
              return false
            end
          end
        end

        return create_certificate
      end

      def login
        UI.message("Starting login with user '#{PEM.config[:username]}'")
        Spaceship.login(PEM.config[:username], nil)
        Spaceship.client.select_team
        UI.message("Successfully logged in")
      end

      def create_certificate
        UI.important("Creating a new push certificate for app '#{PEM.config[:app_identifier]}'.")

        csr, pkey = Spaceship.certificate.create_certificate_signing_request

        begin
          cert = certificate.create!(csr: csr, bundle_id: PEM.config[:app_identifier])
        rescue => ex
          if ex.to_s.include?("You already have a current")
            # That's the most common failure probably
            UI.message(ex.to_s)
            UI.user_error!("You already have 2 active push profiles for this application/environment. You'll need to revoke an old certificate to make room for a new one")
          else
            raise ex
          end
        end

        x509_certificate = cert.download

        filename_base = PEM.config[:pem_name] || "#{certificate_type}_#{PEM.config[:app_identifier]}_#{PEM.config[:platform]}"
        filename_base = File.basename(filename_base, ".pem") # strip off the .pem if it was provided.

        output_path = File.expand_path(PEM.config[:output_path])
        FileUtils.mkdir_p(output_path)

        if PEM.config[:save_private_key]
          private_key_path = File.join(output_path, "#{filename_base}.pkey")
          File.write(private_key_path, pkey.to_pem)
          UI.message("Private key: ".green + Pathname.new(private_key_path).realpath.to_s)
        end

        if PEM.config[:generate_p12]
          p12_cert_path = File.join(output_path, "#{filename_base}.p12")
          p12_password = PEM.config[:p12_password] == "" ? nil : PEM.config[:p12_password]
          p12 = OpenSSL::PKCS12.create(p12_password, certificate_type, pkey, x509_certificate)
          File.write(p12_cert_path, p12.to_der.force_encoding("UTF-8"))
          UI.message("p12 certificate: ".green + Pathname.new(p12_cert_path).realpath.to_s)
        end

        x509_cert_path = File.join(output_path, "#{filename_base}.pem")
        File.write(x509_cert_path, x509_certificate.to_pem + pkey.to_pem)
        UI.message("PEM: ".green + Pathname.new(x509_cert_path).realpath.to_s)
        return x509_cert_path
      end

      def certificate
        if PEM.config[:website_push]
          Spaceship.certificate.website_push
        else
          platform = PEM.config[:platform]
          UI.user_error!('platform parameter is unspecified.') unless platform

          case platform
          when 'ios'
            if PEM.config[:development]
              Spaceship.certificate.development_push
            else
              Spaceship.certificate.production_push
            end
          when 'macos'
            if PEM.config[:development]
              Spaceship.certificate.mac_development_push
            else
              Spaceship.certificate.mac_production_push
            end
          else
            UI.user_error!("Unsupported platform '#{platform}'. Supported platforms for development and production certificates are 'ios' & 'macos'")
          end

        end
      end

      def certificate_type
        if PEM.config[:development]
          'development'
        elsif PEM.config[:website_push]
          'website'
        else
          'production'
        end
      end

      def certificate_sorted
        certificate.all.sort { |x, y| y.expires <=> x.expires }
      end
    end
  end
end
