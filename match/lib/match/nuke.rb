require 'terminal-table'

require 'spaceship'
require 'fastlane_core/provisioning_profile'
require 'fastlane_core/print_table'

require_relative 'module'

require_relative 'storage'
require_relative 'encryption'

module Match
  class Nuke
    attr_accessor :params
    attr_accessor :type

    attr_accessor :certs
    attr_accessor :profiles
    attr_accessor :files

    attr_accessor :storage
    attr_accessor :encryption

    def run(params, type: nil)
      self.params = params
      self.type = type

      update_optional_values_depending_on_storage_type(params)

      self.storage = Storage.for_mode(params[:storage_mode], {
        git_url: params[:git_url],
        shallow_clone: params[:shallow_clone],
        skip_docs: params[:skip_docs],
        git_branch: params[:git_branch],
        git_full_name: params[:git_full_name],
        git_user_email: params[:git_user_email],
        clone_branch_directly: params[:clone_branch_directly],
        google_cloud_bucket_name: params[:google_cloud_bucket_name].to_s,
        google_cloud_keys_file: params[:google_cloud_keys_file].to_s
      })
      self.storage.download

      # After the download was complete
      self.encryption = Encryption.for_storage_mode(params[:storage_mode], {
        git_url: params[:git_url],
        working_directory: storage.working_directory
      })
      self.encryption.decrypt_files if self.encryption

      had_app_identifier = self.params.fetch(:app_identifier, ask: false)
      self.params[:app_identifier] = '' # we don't really need a value here
      FastlaneCore::PrintTable.print_values(config: params,
                                         hide_keys: [:app_identifier],
                                             title: "Summary for match nuke #{Fastlane::VERSION}")

      prepare_list
      print_tables

      if params[:readonly]
        UI.user_error!("`fastlane match nuke` doesn't delete anything when running with --readonly enabled")
      end

      if (self.certs + self.profiles + self.files).count > 0
        unless params[:skip_confirmation]
          UI.error("---")
          UI.error("Are you sure you want to completely delete and revoke all the")
          UI.error("certificates and provisioning profiles listed above? (y/n)")
          UI.error("Warning: By nuking distribution, both App Store and Ad Hoc profiles will be deleted") if type == "distribution"
          UI.error("Warning: The :app_identifier value will be ignored - this will delete all profiles for all your apps!") if had_app_identifier
          UI.error("---")
        end
        if params[:skip_confirmation] || UI.confirm("Do you really want to nuke everything listed above?")
          nuke_it_now!
          UI.success("Successfully cleaned your account ♻️")
        else
          UI.success("Cancelled nuking #thanks 🏠 👨 ‍👩 ‍👧")
        end
      else
        UI.success("No relevant certificates or provisioning profiles found, nothing to nuke here :)")
      end
    end

    # Be smart about optional values here
    # Depending on the storage mode, different values are required
    def update_optional_values_depending_on_storage_type(params)
      if params[:storage_mode] != "git"
        params.option_for_key(:git_url).optional = true
      end
    end

    # Collect all the certs/profiles
    def prepare_list
      UI.message("Fetching certificates and profiles...")
      cert_type = Match.cert_type_sym(type)

      prov_types = []
      prov_types = [:development] if cert_type == :development
      prov_types = [:appstore, :adhoc] if cert_type == :distribution
      prov_types = [:enterprise] if cert_type == :enterprise

      Spaceship.login(params[:username])
      Spaceship.select_team

      if Spaceship.client.in_house? && (type == "distribution" || type == "enterprise")
        UI.error("---")
        UI.error("⚠️ Warning: This seems to be an Enterprise account!")
        UI.error("By nuking your account's distribution, all your apps deployed via ad-hoc will stop working!") if type == "distribution"
        UI.error("By nuking your account's enterprise, all your in-house apps will stop working!") if type == "enterprise"
        UI.error("---")

        UI.user_error!("Enterprise account nuke cancelled") unless UI.confirm("Do you really want to nuke your Enterprise account?")
      end

      self.certs = certificate_type(cert_type).all
      self.profiles = []
      prov_types.each do |prov_type|
        self.profiles += profile_type(prov_type).all
      end

      certs = Dir[File.join(self.storage.working_directory, "**", cert_type.to_s, "*.cer")]
      keys = Dir[File.join(self.storage.working_directory, "**", cert_type.to_s, "*.p12")]
      profiles = []
      prov_types.each do |prov_type|
        profiles += Dir[File.join(self.storage.working_directory, "**", prov_type.to_s, "*.mobileprovision")]
      end

      self.files = certs + keys + profiles
    end

    # Print tables to ask the user
    def print_tables
      puts("")
      if self.certs.count > 0
        rows = self.certs.collect do |cert|
          cert_expiration = cert.expires.nil? ? "Unknown" : cert.expires.strftime("%Y-%m-%d")
          [cert.name, cert.id, cert.class.to_s.split("::").last, cert_expiration]
        end
        puts(Terminal::Table.new({
          title: "Certificates that are going to be revoked".green,
          headings: ["Name", "ID", "Type", "Expires"],
          rows: FastlaneCore::PrintTable.transform_output(rows)
        }))
        puts("")
      end

      if self.profiles.count > 0
        rows = self.profiles.collect do |p|
          status = p.status == 'Active' ? p.status.green : p.status.red

          # Expires is somtimes nil
          expires = p.expires ? p.expires.strftime("%Y-%m-%d") : nil
          [p.name, p.id, status, p.type, expires]
        end
        puts(Terminal::Table.new({
          title: "Provisioning Profiles that are going to be revoked".green,
          headings: ["Name", "ID", "Status", "Type", "Expires"],
          rows: FastlaneCore::PrintTable.transform_output(rows)
        }))
        puts("")
      end

      if self.files.count > 0
        rows = self.files.collect do |f|
          components = f.split(File::SEPARATOR)[-3..-1]

          # from "...1o7xtmh/certs/distribution/8K38XUY3AY.cer" to "distribution cert"
          file_type = components[0..1].reverse.join(" ")[0..-2]

          [file_type, components[2]]
        end

        puts(Terminal::Table.new({
          title: "Files that are going to be deleted".green + "\n" + self.storage.human_readable_description,
          headings: ["Type", "File Name"],
          rows: rows
        }))
        puts("")
      end
    end

    def nuke_it_now!
      UI.header("Deleting #{self.profiles.count} provisioning profiles...") unless self.profiles.count == 0
      self.profiles.each do |profile|
        UI.message("Deleting profile '#{profile.name}' (#{profile.id})...")
        begin
          profile.delete!
        rescue => ex
          UI.message(ex.to_s)
        end
        UI.success("Successfully deleted profile")
      end

      UI.header("Revoking #{self.certs.count} certificates...") unless self.certs.count == 0
      self.certs.each do |cert|
        UI.message("Revoking certificate '#{cert.name}' (#{cert.id})...")
        begin
          cert.revoke!
        rescue => ex
          UI.message(ex.to_s)
        end
        UI.success("Successfully deleted certificate")
      end

      if self.files.count > 0
        files_to_delete = delete_files!
      end

      self.encryption.encrypt_files if self.encryption

      # Now we need to commit and push all this too
      message = ["[fastlane]", "Nuked", "files", "for", type.to_s].join(" ")
      self.storage.save_changes!(files_to_commit: [],
                                 files_to_delete: files_to_delete,
                                 custom_message: message)
    end

    private

    def delete_files!
      UI.header("Deleting #{self.files.count} files from the storage...")

      return self.files.collect do |file|
        UI.message("Deleting file '#{File.basename(file)}'...")

        # Check if the profile is installed on the local machine
        if file.end_with?("mobileprovision")
          parsed = FastlaneCore::ProvisioningProfile.parse(file)
          uuid = parsed["UUID"]
          path = Dir[File.join(FastlaneCore::ProvisioningProfile.profiles_path, "#{uuid}.mobileprovision")].last
          File.delete(path) if path
        end

        File.delete(file)
        UI.success("Successfully deleted file")

        file
      end
    end

    # The kind of certificate we're interested in
    def certificate_type(type)
      {
        distribution: Spaceship.certificate.production,
        development:  Spaceship.certificate.development,
        enterprise:   Spaceship.certificate.in_house
      }[type] ||= raise "Unknown type '#{type}'"
    end

    # The kind of provisioning profile we're interested in
    def profile_type(prov_type)
      {
        appstore:    Spaceship.provisioning_profile.app_store,
        development: Spaceship.provisioning_profile.development,
        enterprise:  Spaceship.provisioning_profile.in_house,
        adhoc:       Spaceship.provisioning_profile.ad_hoc
      }[prov_type] ||= raise "Unknown provisioning type '#{prov_type}'"
    end
  end
end
