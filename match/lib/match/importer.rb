require_relative 'spaceship_ensure'
require_relative 'encryption'
require_relative 'storage'
require_relative 'module'
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
      storage = Storage.for_mode(params[:storage_mode], {
        git_url: params[:git_url],
        shallow_clone: params[:shallow_clone],
        skip_docs: params[:skip_docs],
        git_branch: params[:git_branch],
        git_full_name: params[:git_full_name],
        git_user_email: params[:git_user_email],
        clone_branch_directly: params[:clone_branch_directly],
        type: params[:type].to_s,
        platform: params[:platform].to_s,
        google_cloud_bucket_name: params[:google_cloud_bucket_name].to_s,
        google_cloud_keys_file: params[:google_cloud_keys_file].to_s,
        google_cloud_project_id: params[:google_cloud_project_id].to_s,
        readonly: params[:readonly],
        username: params[:username],
        team_id: params[:team_id],
        team_name: params[:team_name]
      })
      storage.download

      # Encryption
      encryption = Encryption.for_storage_mode(params[:storage_mode], {
        git_url: params[:git_url],
        working_directory: storage.working_directory
      })
      encryption.decrypt_files if encryption
      UI.success("Repo is at: '#{storage.working_directory}'")

      # Map match type into Spaceship::ConnectAPI::Certificate::CertificateType
      cert_type = Match.cert_type_sym(params[:type])

      case cert_type
      when :development
        certificate_type = Spaceship::ConnectAPI::Certificate::CertificateType::IOS_DEVELOPMENT + "," + Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPMENT
      when :distribution, :enterprise
        certificate_type = Spaceship::ConnectAPI::Certificate::CertificateType::IOS_DISTRIBUTION + "," + Spaceship::ConnectAPI::Certificate::CertificateType::DISTRIBUTION
      when :developer_id_application
        certificate_type = Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPER_ID_APPLICATION
      else
        UI.user_error!("Cert type '#{cert_type}' is not supported")
      end

      output_dir_certs = File.join(storage.prefixed_working_directory, "certs", cert_type.to_s)
      output_dir_profiles = File.join(storage.prefixed_working_directory, "profiles", cert_type.to_s)

      # Need to get the cert id by comparing base64 encoded cert content with certificate content from the API responses
      Spaceship::Portal.login(params[:username])
      Spaceship::Portal.select_team(team_id: params[:team_id], team_name: params[:team_name])
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

      files_to_commit = [dest_cert_path, dest_p12_path]

      # Copy files
      IO.copy_stream(cert_path, dest_cert_path)
      IO.copy_stream(p12_path, dest_p12_path)
      unless profile_path.nil?
        FileUtils.mkdir_p(output_dir_profiles)
        bundle_id = FastlaneCore::ProvisioningProfile.bundle_id(profile_path)
        profile_extension = FastlaneCore::ProvisioningProfile.profile_extension(profile_path)
        dest_profile_path = File.join(output_dir_profiles, "#{cert_type.to_s.capitalize}_#{bundle_id}#{profile_extension}")
        files_to_commit.push(dest_profile_path)
        IO.copy_stream(profile_path, dest_profile_path)
      end

      # Encrypt and commit
      encryption.encrypt_files if encryption
      storage.save_changes!(files_to_commit: files_to_commit)
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
