require_relative 'spaceship_ensure'
require_relative 'encryption'
require_relative 'storage'
require_relative 'module'
require 'fileutils'

module Match
  class Importer
    def import_cert(params, cert_path: nil, p12_path: nil)
      runner = Match::Runner.new
      runner.storage_mode = params[:storage_mode]

      # Get and verify cert and p12 path
      cert_path ||= UI.input("Cert path:")
      p12_path ||= UI.input("p12 path:")

      raise "No cert path" if !File.exist?(cert_path)
      raise "No p12 path" if !File.exist?(p12_path)

      cert_contents_base_64 = Base64.strict_encode64(File.open(cert_path).read)

      # Storage
      storage = Storage.for_mode(params[:storage_mode], {
        git_url: params[:git_url],
        shallow_clone: params[:shallow_clone],
        git_branch: params[:git_branch],
        clone_branch_directly: params[:clone_branch_directly]
      })
      storage.download

      # Encryption
      encryption = Encryption.for_storage_mode(params[:storage_mode], {
        git_url: params[:git_url],
        working_directory: storage.working_directory
      })
      encryption.decrypt_files if encryption
      UI.success("Repo is at: '#{storage.working_directory}'")

      # Type
      type = params[:type]
      cert_type = Match.cert_type_sym(params[:type])
      case cert_type
      when :distribution
        certificate_type = "IOS_DISTRIBUTION" 
      else
       raise "type not supported" 
      end

      output_dir = File.join(runner.prefixed_working_directory(storage.working_directory), "certs", cert_type.to_s)

      #
      # Need to get the cert id
      #
      Spaceship::Portal.login(params[:username])
      Spaceship::Portal.select_team(team_id: params[:team_id] ,team_name: params[:team_name])
      certs = Spaceship::ConnectAPI::Certificate.all(filter: {certificateType: certificate_type})

      cert = certs.find do |cert|
        cert.certificate_content == cert_contents_base_64
      end

      # Make dir if doesn't exist 
      FileUtils.mkdir_p(output_dir)  

      # Copy files
      IO.copy_stream(cert_path, File.join(output_dir, "#{cert.id}.cer"))
      IO.copy_stream(p12_path, File.join(output_dir, "#{cert.id}.p12"))

      files_to_commit = [
        File.join(output_dir, "#{cert.id}.cer"),
        File.join(output_dir, "#{cert.id}.p12")
      ]

      # Encrypt and commit
      encryption.encrypt_files
      storage.save_changes!(files_to_commit: files_to_commit)
    end
  end
end
