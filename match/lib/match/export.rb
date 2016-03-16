module Match
  class Export
    attr_accessor :params
    attr_accessor :type

    attr_accessor :certs
    attr_accessor :keys
    attr_accessor :profiles
    attr_accessor :files

    def run(params, type: nil)
      self.params = params
      self.type = type
      params[:workspace] = GitHelper.clone(params[:git_url], params[:shallow_clone])
      FastlaneCore::PrintTable.print_values(config: params,
                                         hide_keys: [:workspace],
                                             title: "Summary for match export #{Match::VERSION}")

      unless params[:zip_file]
        UI.error "No Zip file specified"
        return
      end
      prepare_list
      print_tables

      if self.profiles.count == 0
        UI.error "No Profiles found"
        raise "No Profiles found"
      end
      if self.keys.count == 0
        UI.error "No Profiles found"
        raise "No Profiles found"
      end

      if (self.certs + self.profiles + self.keys + self.files).count > 0
        Fastlane::Actions.verify_gem!('zip')
        require 'zip'

        if File.file?(params[:zip_file])
          if !params[:force]
            UI.error "Zip file already exists: #{params[:zip_file]} and force not specified"
            raise "Export ZIP file already exists"
          else
            File.delete(params[:zip_file])
            UI.important("Removing existing ZIP file: #{params[:zip_file]}")
          end
        end
        Zip::File.open(params[:zip_file], Zip::File::CREATE) do |zipfile|
          self.files.each do |filename|
            zipfile.add(filename.gsub(params[:workspace] + "/", ""), filename)
          end
        end
        UI.success "Exported to: #{params[:zip_file]}"
        GitHelper.clear_changes
      end
    end

    # Collect all the certs/profiles
    def prepare_list
      UI.message "Fetching certificates and profiles..."
      cert_type = type.to_sym

      prov_types = [:development]
      prov_types = [:appstore, :adhoc] if cert_type == :distribution

      Spaceship.login(params[:username])
      Spaceship.select_team

      self.certs = Dir[File.join(params[:workspace], "**", cert_type.to_s, "*.cer")]
      self.keys = Dir[File.join(params[:workspace], "**", cert_type.to_s, "*.p12")]

      self.profiles = []
      prov_types.each do |prov_type|
        # puts File.join(params[:workspace], "**", prov_type.to_s,"*",params[:app_identifier],  "*.mobileprovision");
        # exit;
        self.profiles += Dir[File.join(params[:workspace], "**", prov_type.to_s, "*_#{params[:app_identifier]}.mobileprovision")]
      end
      self.files = self.certs + self.keys + self.profiles
    end

    # Print tables to ask the user
    def print_tables
      if self.certs.count > 0
        puts Terminal::Table.new({
          title: "Certificates that are going to be exported".green,
          headings: ["Path"],
          rows: self.certs.map { |c| [c] }
        })
        puts ""
      end
      if self.keys.count > 0
        puts Terminal::Table.new({
          title: "Keys that are going to be exported".green,
          headings: ["Path"],
          rows: self.keys.map { |c| [c] }
        })
        puts ""
      end
      if self.profiles.count > 0
        puts Terminal::Table.new({
          title: "Provisioning Profiles that are going to be exported".green,
          headings: ["Path"],
          rows: self.profiles.map do |p|
            [p]
          end
        })
        puts ""
      end
    end

    private

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
