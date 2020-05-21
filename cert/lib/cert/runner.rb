require 'fileutils'
require 'fastlane_core/globals'
require 'fastlane_core/cert_checker'
require 'fastlane_core/keychain_importer'
require 'fastlane_core/print_table'
require 'spaceship'

require_relative 'module'

module Cert
  class Runner
    def launch
      run

      installed = FastlaneCore::CertChecker.installed?(ENV["CER_FILE_PATH"], in_keychain: ENV["CER_KEYCHAIN_PATH"])
      UI.message("Verifying the certificate is properly installed locally...")
      UI.user_error!("Could not find the newly generated certificate installed", show_github_issues: true) unless installed
      UI.success("Successfully installed certificate #{ENV['CER_CERTIFICATE_ID']}")
      return ENV["CER_FILE_PATH"]
    end

    def login
      UI.message("Starting login with user '#{Cert.config[:username]}'")
      Spaceship.login(Cert.config[:username], nil)
      Spaceship.select_team
      UI.message("Successfully logged in")
    end

    def run
      FileUtils.mkdir_p(Cert.config[:output_path])

      FastlaneCore::PrintTable.print_values(config: Cert.config, hide_keys: [:output_path], title: "Summary for cert #{Fastlane::VERSION}")

      login

      should_create = Cert.config[:force]
      unless should_create
        cert_path = find_existing_cert
        should_create = cert_path.nil?
      end

      return unless should_create

      if create_certificate # no certificate here, creating a new one
        return # success
      else
        UI.user_error!("Something went wrong when trying to create a new certificate...")
      end
    end

    # Command method for the :revoke_expired sub-command
    def revoke_expired_certs!
      FastlaneCore::PrintTable.print_values(config: Cert.config, hide_keys: [:output_path], title: "Summary for cert #{Fastlane::VERSION}")

      login

      to_revoke = expired_certs

      if to_revoke.empty?
        UI.success("No expired certificates were found to revoke! 👍")
        return
      end

      revoke_count = 0

      to_revoke.each do |certificate|
        begin
          UI.message("#{certificate.id} #{certificate.name} has expired, revoking...")
          certificate.revoke!
          revoke_count += 1
        rescue => e
          UI.error("An error occurred while revoking #{certificate.id} #{certificate.name}")
          UI.error("#{e.message}\n#{e.backtrace.join("\n")}") if FastlaneCore::Globals.verbose?
        end
      end

      UI.success("#{revoke_count} expired certificate#{'s' if revoke_count != 1} #{revoke_count == 1 ? 'has' : 'have'} been revoked! 👍")
    end

    def expired_certs
      certificates.select do |certificate|
        certificate.expires < Time.now.utc
      end
    end

    def find_existing_cert
      certificates.each do |certificate|
        unless certificate.can_download
          next
        end

        path = store_certificate(certificate, Cert.config[:filename])
        private_key_path = File.expand_path(File.join(Cert.config[:output_path], "#{certificate.id}.p12"))

        # As keychain is specific to macOS, this will likely fail on non macOS systems.
        # See also: https://github.com/fastlane/fastlane/pull/14462
        keychain = File.expand_path(Cert.config[:keychain_path]) unless Cert.config[:keychain_path].nil?
        if FastlaneCore::CertChecker.installed?(path, in_keychain: keychain)
          # This certificate is installed on the local machine
          ENV["CER_CERTIFICATE_ID"] = certificate.id
          ENV["CER_FILE_PATH"] = path
          ENV["CER_KEYCHAIN_PATH"] = keychain

          UI.success("Found the certificate #{certificate.id} (#{certificate.name}) which is installed on the local machine. Using this one.")

          return path
        elsif File.exist?(private_key_path)
          password = Cert.config[:keychain_password]
          FastlaneCore::KeychainImporter.import_file(private_key_path, keychain, keychain_password: password)
          FastlaneCore::KeychainImporter.import_file(path, keychain, keychain_password: password)

          ENV["CER_CERTIFICATE_ID"] = certificate.id
          ENV["CER_FILE_PATH"] = path
          ENV["CER_KEYCHAIN_PATH"] = keychain

          UI.success("Found the cached certificate #{certificate.id} (#{certificate.name}). Using this one.")

          return path
        else
          UI.error("Certificate #{certificate.id} (#{certificate.name}) can't be found on your local computer")
        end

        File.delete(path) # as apparently this certificate is pretty useless without a private key
      end

      UI.important("Couldn't find an existing certificate... creating a new one")
      return nil
    end

    # All certificates of this type
    def certificates
      certificate_type.all
    end

    # The kind of certificate we're interested in
    def certificate_type
      if Cert.config[:type]
        case Cert.config[:type].to_sym
        when :mac_installer_distribution
          return Spaceship.certificate.mac_installer_distribution
        when :developer_id_application
          return Spaceship.certificate.developer_id_application
        when :developer_id_installer
          return Spaceship.certificate.developer_id_installer
        else
          UI.user_error("Unaccepted value for :type - #{Cert.config[:type]}")
        end
      end

      # Check if apple certs (Xcode 11 and later) should be used
      if Cert.config[:generate_apple_certs]
        cert_type = Spaceship.certificate.apple_distribution
        cert_type = Spaceship.certificate.in_house if Spaceship.client.in_house? # Enterprise doesn't use Apple Distribution
        cert_type = Spaceship.certificate.apple_development if Cert.config[:development]
      else
        case Cert.config[:platform].to_s
        when 'ios', 'tvos'
          cert_type = Spaceship.certificate.production
          cert_type = Spaceship.certificate.in_house if Spaceship.client.in_house?
          cert_type = Spaceship.certificate.development if Cert.config[:development]

        when 'macos'
          cert_type = Spaceship.certificate.mac_app_distribution
          cert_type = Spaceship.certificate.mac_development if Cert.config[:development]
        end
      end

      return cert_type
    end

    def create_certificate
      # Create a new certificate signing request
      csr, pkey = Spaceship.certificate.create_certificate_signing_request

      # Use the signing request to create a new (development|distribution) certificate
      begin
        certificate = certificate_type.create!(csr: csr)
      rescue => ex
        type_name = (Cert.config[:development] ? "Development" : "Distribution")
        if ex.to_s.include?("You already have a current")
          UI.user_error!("Could not create another #{type_name} certificate, reached the maximum number of available #{type_name} certificates.", show_github_issues: true)
        elsif ex.to_s.include?("You are not allowed to perform this operation.") && type_name == "Distribution"
          UI.user_error!("You do not have permission to create this certificate. Only Team Admins can create Distribution certificates\n 🔍 See https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/ManagingYourTeam/ManagingYourTeam.html for more information.")
        end
        raise ex
      end

      # Store all that onto the filesystem

      request_path = File.expand_path(File.join(Cert.config[:output_path], "#{certificate.id}.certSigningRequest"))
      File.write(request_path, csr.to_pem)

      private_key_path = File.expand_path(File.join(Cert.config[:output_path], "#{certificate.id}.p12"))
      File.write(private_key_path, pkey)

      cert_path = store_certificate(certificate, Cert.config[:filename])

      # Import all the things into the Keychain
      keychain = File.expand_path(Cert.config[:keychain_path])
      password = Cert.config[:keychain_password]
      FastlaneCore::KeychainImporter.import_file(private_key_path, keychain, keychain_password: password)
      FastlaneCore::KeychainImporter.import_file(cert_path, keychain, keychain_password: password)

      # Environment variables for the fastlane action
      ENV["CER_CERTIFICATE_ID"] = certificate.id
      ENV["CER_FILE_PATH"] = cert_path

      UI.success("Successfully generated #{certificate.id} which was imported to the local machine.")

      return cert_path
    end

    def store_certificate(certificate, filename = nil)
      cert_name = filename ? filename : certificate.id
      cert_name = "#{cert_name}.cer" unless File.extname(cert_name) == ".cer"
      path = File.expand_path(File.join(Cert.config[:output_path], cert_name))
      raw_data = certificate.download_raw
      File.write(path, raw_data)
      return path
    end
  end
end
