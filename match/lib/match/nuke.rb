module Match
  class Nuke
    attr_accessor :params
    attr_accessor :type

    attr_accessor :certs
    attr_accessor :profiles
    attr_accessor :files

    def run(params, type: nil)
      self.params = params
      self.type = type

      params[:workspace] = GitHelper.clone(params[:git_url], params[:shallow_clone], skip_docs: params[:skip_docs], branch: params[:git_branch])

      had_app_identifier = self.params[:app_identifier]
      self.params[:app_identifier] = '' # we don't really need a value here
      FastlaneCore::PrintTable.print_values(config: params,
                                         hide_keys: [:app_identifier, :workspace],
                                             title: "Summary for match nuke #{Fastlane::VERSION}")

      prepare_list
      print_tables

      if params[:readonly]
        UI.user_error!("`match nuke` doesn't delete anything when running with --readonly enabled")
      end

      if (self.certs + self.profiles + self.files).count > 0
        unless params[:skip_confirmation]
          UI.error "---"
          UI.error "Are you sure you want to completely delete and revoke all the"
          UI.error "certificates and provisioning profiles listed above? (y/n)"
          UI.error "Warning: By nuking distribution, both App Store and Ad Hoc profiles will be deleted" if type == "distribution"
          UI.error "Warning: The :app_identifier value will be ignored - this will delete all profiles for all your apps!" if had_app_identifier
          UI.error "---"
        end
        if params[:skip_confirmation] || agree("(y/n)", true)
          nuke_it_now!
          UI.success "Successfully cleaned your account ♻️"
        else
          UI.success "Cancelled nuking #thanks 🏠 👨 ‍👩 ‍👧"
        end
      else
        UI.success "No relevant certificates or provisioning profiles found, nothing to nuke here :)"
      end
    end

    # Collect all the certs/profiles
    def prepare_list
      UI.message "Fetching certificates and profiles..."
      cert_type = Match.cert_type_sym(type)

      prov_types = [:development]
      prov_types = [:appstore, :adhoc] if cert_type == :distribution

      Spaceship.login(params[:username])
      Spaceship.select_team

      self.certs = certificate_type(cert_type).all
      self.profiles = []
      prov_types.each do |prov_type|
        self.profiles += profile_type(prov_type).all
      end

      certs = Dir[File.join(params[:workspace], "**", cert_type.to_s, "*.cer")]
      keys = Dir[File.join(params[:workspace], "**", cert_type.to_s, "*.p12")]
      profiles = []
      prov_types.each do |prov_type|
        profiles += Dir[File.join(params[:workspace], "**", prov_type.to_s, "*.mobileprovision")]
      end

      self.files = certs + keys + profiles
    end

    # Print tables to ask the user
    def print_tables
      puts ""
      if self.certs.count > 0
        puts Terminal::Table.new({
          title: "Certificates that are going to be revoked".green,
          headings: ["Name", "ID", "Type", "Expires"],
          rows: self.certs.collect { |c| [c.name, c.id, c.class.to_s.split("::").last, c.expires.strftime("%Y-%m-%d")] }
        })
        puts ""
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
        puts ""
      end

      if self.files.count > 0
        puts Terminal::Table.new({
          title: "Files that are going to be deleted".green,
          headings: ["Type", "File Name"],
          rows: self.files.collect do |f|
            components = f.split(File::SEPARATOR)[-3..-1]

            # from "...1o7xtmh/certs/distribution/8K38XUY3AY.cer" to "distribution cert"
            file_type = components[0..1].reverse.join(" ")[0..-2]

            [file_type, components[2]]
          end
        })
        puts ""
      end
    end

    def nuke_it_now!
      UI.header "Deleting #{self.profiles.count} provisioning profiles..." unless self.profiles.count == 0
      self.profiles.each do |profile|
        UI.message "Deleting profile '#{profile.name}' (#{profile.id})..."
        begin
          profile.delete!
        rescue => ex
          UI.message(ex.to_s)
        end
        UI.success "Successfully deleted profile"
      end

      UI.header "Revoking #{self.certs.count} certificates..." unless self.certs.count == 0
      self.certs.each do |cert|
        UI.message "Revoking certificate '#{cert.name}' (#{cert.id})..."
        begin
          cert.revoke!
        rescue => ex
          UI.message(ex.to_s)
        end
        UI.success "Successfully deleted certificate"
      end

      if self.files.count > 0
        delete_files!
      end

      # Now we need to commit and push all this too
      message = ["[fastlane]", "Nuked", "files", "for", type.to_s].join(" ")
      GitHelper.commit_changes(params[:workspace], message, self.params[:git_url], params[:git_branch])
    end

    private

    def delete_files!
      UI.header "Deleting #{self.files.count} files from the git repo..."

      self.files.each do |file|
        UI.message "Deleting file '#{File.basename(file)}'..."

        # Check if the profile is installed on the local machine
        if file.end_with?("mobileprovision")
          parsed = FastlaneCore::ProvisioningProfile.parse(file)
          uuid = parsed["UUID"]
          path = Dir[File.join(FastlaneCore::ProvisioningProfile.profiles_path, "#{uuid}.mobileprovision")].last
          File.delete(path) if path
        end

        File.delete(file)
        UI.success "Successfully deleted file"
      end
    end

    # The kind of certificate we're interested in
    def certificate_type(type)
      cert_type = Spaceship.certificate.production
      cert_type = Spaceship.certificate.development if type == :development
      cert_type = Spaceship.certificate.in_house if Match.enterprise? && Spaceship.client.in_house?

      cert_type
    end

    # The kind of provisioning profile we're interested in
    def profile_type(type)
      profile_type = Spaceship.provisioning_profile.app_store
      profile_type = Spaceship.provisioning_profile.in_house if Match.enterprise? && Spaceship.client.in_house?
      profile_type = Spaceship.provisioning_profile.ad_hoc if type == :adhoc
      profile_type = Spaceship.provisioning_profile.development if type == :development

      profile_type
    end
  end
end
