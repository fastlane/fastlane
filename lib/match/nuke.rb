require 'pry'
module Match
  class Nuke
    attr_accessor :params

    attr_accessor :certs
    attr_accessor :profiles
    attr_accessor :files

    def run(params)
      self.params = params
      self.params[:path] = GitHelper.clone(self.params[:git_url])
      self.params[:app_identifier] = '' # we don't really need a value here
      FastlaneCore::PrintTable.print_values(config: params,
                                         hide_keys: [:app_identifier],
                                             title: "Summary for match nuke #{Match::VERSION}")

      prepare_list
      print_tables

      if (self.certs + self.profiles + self.files).count > 0
        Helper.log.info "---".red
        Helper.log.info "Are you sure you want to completely delete and revoke all the".red
        Helper.log.info "certificates and provisioning profiles listed above? (y/n)".red
        if params[:type] == "appstore" or params[:type] == "adhoc"
          Helper.log.info "Warning: By nuking AppStore/AdHoc profiles, the distribution certificate gets revoked!".red
        end
        Helper.log.info "---".red
        return unless agree("(y/n)", true)

        nuke_it_now!

        Helper.log.info "Successfully cleaned your account ♻️".green
      else
        Helper.log.info "No relevant certificates or provisioning profiles found, nothing to do here :)".green
      end
    end

    # Collect all the certs/profiles
    def prepare_list
      Helper.log.info "Fetching certificates and profiles..."
      cert_type = :distribution
      cert_type = :development if params[:type] == "development"
      prov_type = params[:type].to_sym

      Spaceship.login(params[:username])
      Spaceship.select_team

      self.certs = certificate_type(cert_type).all
      self.profiles = profile_type(prov_type).all

      certs = Dir[File.join(params[:path], "**", cert_type.to_s, "*.cer")]
      keys = Dir[File.join(params[:path], "**", cert_type.to_s, "*.p12")]
      profiles = Dir[File.join(params[:path], "**", prov_type.to_s, "*.mobileprovision")]
      self.files = certs + keys + profiles
    end

    # Print tables to ask the user
    def print_tables
      if self.certs.count > 0
        puts Terminal::Table.new({
          title: "Certificates that are going to be revoked".green,
          headings: ["Name", "ID", "Type", "Expires"],
          rows: self.certs.collect { |c| [c.name, c.id, c.class.to_s.split("::").last, c.expires.strftime("%Y-%m-%d")] }
        })
      end

      if self.profiles.count > 0
        puts Terminal::Table.new({
          title: "Provisioning Profiles that are going to be revoked".green,
          headings: ["Name", "ID", "Status", "Type", "Expires"],
          rows: self.profiles.collect do |p|
            status = p.status == 'Active' ? p.status.green : p.status.red

            [p.name, p.id, status, p.type, p.expires.strftime("%Y-%m-%d")]
          end
        })
      end

      if self.files.count > 0
        puts Terminal::Table.new({
          title: "Files that are going to be deleted".green,
          headings: ["Type", "File Name"],
          rows: self.files.collect do |f|
            components = f.split(File::SEPARATOR)[-3..-1]
            [components[0..1].join(" "), components[2]]
          end
        })
      end
    end

    def nuke_it_now!
      Helper.log_alert "Deleting #{self.profiles.count} provisioning profiles..." unless self.profiles.count == 0
      self.profiles.each do |profile|
        Helper.log.info "Deleting profile '#{profile.name}' (#{profile.id})..."
        profile.delete!
        Helper.log.info "Successfully deleted profile".green
      end

      Helper.log_alert "Revoking #{self.certs.count} certificates..." unless self.certs.count == 0
      self.certs.each do |cert|
        Helper.log.info "Revoking certificate '#{cert.name}' (#{cert.id})..."
        cert.revoke!
        Helper.log.info "Successfully deleted certificate".green
      end

      if self.files.count > 0
        Helper.log_alert "Deleting #{self.files.count} files from the git repo..."

        self.files.each do |file|
          Helper.log.info "Deleting file '#{File.basename(file)}'..."

          # Check if the profile is installed on the local machine
          if file.end_with?("mobileprovision")
            parsed = FastlaneCore::ProvisioningProfile.parse(file)
            uuid = parsed["UUID"]
            path = Dir[File.join(FastlaneCore::ProvisioningProfile.profiles_path, "#{uuid}.mobileprovision")].last
            File.delete(path) if path
          end

          File.delete(file)
          Helper.log.info "Successfully deleted file".green
        end

        # Now we need to commit and push all this too
        message = ["[fastlane]", "Nuked", "files", "for", params[:type].to_s].join(" ")
        GitHelper.commit_changes(params[:path], message)
      end
    end

    private

    # The kind of certificate we're interested in
    def certificate_type(type)
      cert_type = Spaceship.certificate.production
      cert_type = Spaceship.certificate.development if type == :development
      # cert_type = Spaceship.certificate.in_house if Spaceship.client.in_house?

      cert_type
    end

    # The kind of provisioning profile we're interested in
    def profile_type(type)
      profile_type = Spaceship.provisioning_profile.app_store
      # profile_type = Spaceship.provisioning_profile.in_house if Spaceship.client.in_house?
      profile_type = Spaceship.provisioning_profile.ad_hoc if type == :adhoc
      profile_type = Spaceship.provisioning_profile.development if type == :development

      profile_type
    end
  end
end
