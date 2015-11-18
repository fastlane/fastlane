require 'pry'
module Fastfix
  class Nuke
    attr_accessor :params

    attr_accessor :certs

    attr_accessor :profiles

    def run(params)
      self.params = params
      FastlaneCore::PrintTable.print_values(config: params,
                                             title: "Summary for fastfix nuke #{Fastfix::VERSION}")

      prepare_list
      print_tables

      Helper.log_alert("Are you sure you want to complete delete and revoke all the certificates and provisioning profiles listed above? (y/n)".red)
      return unless agree("", true)

      nuke_it_now!

      Helper.log.info "Successfully cleaned your account ♻️".green
    end

    # Collect all the certs/profiles
    def prepare_list
      Helper.log.info "Fetching certificates and profiles..."
      cert_type = :distribution
      cert_type = :development if params[:type] == "development"
      prov_type = params[:type]

      Spaceship.login(params[:username])
      Spaceship.select_team

      self.certs = certificate_type(cert_type).all
      self.profiles = profile_type(prov_type).all
    end

    # Print tables to ask the user
    def print_tables
      if self.certs.count > 0
        puts Terminal::Table.new({
          title: "Certificates that are going to be revoked".red,
          headings: ["Name", "ID", "Expires"],
          rows: self.certs.collect { |c| [c.name, c.id, c.expires.strftime("%Y-%m-%d")] },
        })
      end

      if self.profiles.count > 0
        puts Terminal::Table.new({
          title: "Provisioning Profiles that are going to be revoked".red,
          headings: ["Name", "ID", "Status", "Type", "Expires"],
          rows: self.profiles.collect do |p| 
            status = p.status == 'Active' ? p.status.green : p.status.red

            [p.name, p.id, status, p.type, p.expires.strftime("%Y-%m-%d")]
          end
        })
      end
    end

    def nuke_it_now!
      # TODO
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
