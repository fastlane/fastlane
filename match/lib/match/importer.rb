require_relative 'spaceship_ensure'
require_relative 'encryption'
require_relative 'storage'
require_relative 'module'
require_relative 'generator'
require 'fastlane_core/provisioning_profile'
require 'fileutils'

module Match
  class Importer
    def import_cert(params, cert_path: nil, p12_path: nil, profile_path: nil)
      # Get and verify cert, p12 and profiles path
      cert_path = ensure_valid_file_path(cert_path, "Certificate", ".cer")
      p12_path = ensure_valid_file_path(p12_path, "Private key", ".p12")
      profile_path = ensure_valid_file_path(profile_path, "Provisioning profile", ".mobileprovision or .provisionprofile", optional: true)

      # Storage
      storage = Storage.from_params(params)
      storage.download

      # Encryption
      encryption = Encryption.for_storage_mode(params[:storage_mode], {
        git_url: params[:git_url],
        s3_bucket: params[:s3_bucket],
        s3_skip_encryption: params[:s3_skip_encryption],
        working_directory: storage.working_directory,
        force_legacy_encryption: params[:force_legacy_encryption]
      })
      encryption.decrypt_files if encryption
      UI.success("Repo is at: '#{storage.working_directory}'")

      # Map match type into Spaceship::ConnectAPI::Certificate::CertificateType
      cert_type = Match.cert_type_sym(params[:type])

      case cert_type
      when :development
        certificate_type = [
          Spaceship::ConnectAPI::Certificate::CertificateType::IOS_DEVELOPMENT,
          Spaceship::ConnectAPI::Certificate::CertificateType::MAC_APP_DEVELOPMENT,
          Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPMENT
        ].join(',')
      when :distribution, :enterprise
        certificate_type = [
          Spaceship::ConnectAPI::Certificate::CertificateType::IOS_DISTRIBUTION,
          Spaceship::ConnectAPI::Certificate::CertificateType::MAC_APP_DISTRIBUTION,
          Spaceship::ConnectAPI::Certificate::CertificateType::DISTRIBUTION
        ].join(',')
      when :developer_id_application
        certificate_type = [
          Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPER_ID_APPLICATION,
          Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPER_ID_APPLICATION_G2
        ].join(',')
      when :mac_installer_distribution
        certificate_type = [
          Spaceship::ConnectAPI::Certificate::CertificateType::MAC_INSTALLER_DISTRIBUTION
        ].join(',')
      when :developer_id_installer
        certificate_type = [
          Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPER_ID_INSTALLER
        ].join(',')
      else
        UI.user_error!("Cert type '#{cert_type}' is not supported")
      end

      prov_type = Match.profile_type_sym(params[:type])
      output_dir_certs = File.join(storage.prefixed_working_directory, "certs", cert_type.to_s)
      output_dir_profiles = File.join(storage.prefixed_working_directory, "profiles", prov_type.to_s)

      should_skip_certificate_matching = params[:skip_certificate_matching]
      # In case there is no access to Apple Developer portal but we have the certificates, keys and profiles
      if should_skip_certificate_matching
        cert_name = File.basename(cert_path, ".*")
        p12_name = File.basename(p12_path, ".*")

        # Make dir if doesn't exist
        FileUtils.mkdir_p(output_dir_certs)
        dest_cert_path = File.join(output_dir_certs, "#{cert_name}.cer")
        dest_p12_path = File.join(output_dir_certs, "#{p12_name}.p12")
      else
        if (api_token = Spaceship::ConnectAPI::Token.from(hash: params[:api_key], filepath: params[:api_key_path]))
          UI.message("Creating authorization token for App Store Connect API")
          Spaceship::ConnectAPI.token = api_token
        elsif !Spaceship::ConnectAPI.token.nil?
          UI.message("Using existing authorization token for App Store Connect API")
        else
          UI.message("Login to App Store Connect (#{params[:username]})")
          Spaceship::ConnectAPI.login(params[:username], use_portal: true, use_tunes: false, portal_team_id: params[:team_id], team_name: params[:team_name])
        end

        # Need to get the cert id by comparing base64 encoded cert content with certificate content from the API responses
        certs = Spaceship::ConnectAPI::Certificate.all(filter: { certificateType: certificate_type })

        # Base64 encode contents to find match from API to find a cert ID
        cert_contents_base_64 = Base64.strict_encode64(File.binread(cert_path))
        matching_cert = certs.find do |cert|
          cert.certificate_content == cert_contents_base_64
        end

        UI.user_error!("This certificate cannot be imported - the certificate contents did not match with any available on the Developer Portal") if matching_cert.nil?

        # Make dir if doesn't exist
        FileUtils.mkdir_p(output_dir_certs)
        dest_cert_path = File.join(output_dir_certs, "#{matching_cert.id}.cer")
        dest_p12_path = File.join(output_dir_certs, "#{matching_cert.id}.p12")
      end

      files_to_commit = [dest_cert_path, dest_p12_path]

      # Copy files
      IO.copy_stream(cert_path, dest_cert_path)
      IO.copy_stream(p12_path, dest_p12_path)
      unless profile_path.nil?
        FileUtils.mkdir_p(output_dir_profiles)
        bundle_id = FastlaneCore::ProvisioningProfile.bundle_id(profile_path)
        profile_extension = FastlaneCore::ProvisioningProfile.profile_extension(profile_path)
        profile_type_name = Match::Generator.profile_type_name(prov_type)
        dest_profile_path = File.join(output_dir_profiles, "#{profile_type_name}_#{bundle_id}#{profile_extension}")
        files_to_commit.push(dest_profile_path)
        IO.copy_stream(profile_path, dest_profile_path)
      end

      # Encrypt and commit
      encryption.encrypt_files if encryption
      storage.save_changes!(files_to_commit: files_to_commit)
    ensure
      storage.clear_changes if storage
    end

    def ensure_valid_file_path(file_path, file_description, file_extension, optional: false)
      optional_file_message = optional ? " or leave empty to skip this file" : ""
      file_path ||= UI.input("#{file_description} (#{file_extension}) path#{optional_file_message}:")

      file_path = File.absolute_path(file_path) unless file_path == ""
      file_path = File.exist?(file_path) ? file_path : nil
      UI.user_error!("#{file_description} does not exist at path: #{file_path}") unless !file_path.nil? || optional
      file_path
    end
  end
end
