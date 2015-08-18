require 'spaceship'

module Sigh
  class Runner
    attr_accessor :spaceship

    # Uses the spaceship to create or download a provisioning profile
    # returns the path the newly created provisioning profile (in /tmp usually)
    def run
      Helper.log.info "Starting login"
      Spaceship.login(Sigh.config[:username], nil)
      Spaceship.select_team
      Helper.log.info "Successfully logged in"

      profiles = [] if Sigh.config[:skip_fetch_profiles]
      profiles ||= fetch_profiles # download the profile if it's there

      if profiles.count > 0
        Helper.log.info "Found #{profiles.count} matching profile(s)".yellow
        profile = profiles.first

        if Sigh.config[:force]
          if profile_type == Spaceship.provisioning_profile::AppStore or profile_type == Spaceship.provisioning_profile::InHouse
            Helper.log.info "Updating the provisioning profile".yellow
          else
            Helper.log.info "Updating the profile to include all devices".yellow
            profile.devices = Spaceship.device.all
          end

          profile = profile.update! # assign it, as it's a new profile
        end
      else
        Helper.log.info "No existing profiles, creating a new one for you".yellow
        profile = create_profile!
      end

      raise "Something went wrong fetching the latest profile".red unless profile

      return download_profile(profile)
    end

    # The kind of provisioning profile we're interested in
    def profile_type
      return @profile_type if @profile_type

      @profile_type = Spaceship.provisioning_profile.app_store
      @profile_type = Spaceship.provisioning_profile.in_house if Spaceship.client.in_house?
      @profile_type = Spaceship.provisioning_profile.ad_hoc if Sigh.config[:adhoc]
      @profile_type = Spaceship.provisioning_profile.development if Sigh.config[:development]

      @profile_type
    end

    # Fetches a profile matching the user's search requirements
    def fetch_profiles
      Helper.log.info "Fetching profiles..."
      results = profile_type.find_by_bundle_id(Sigh.config[:app_identifier]).find_all { |a| a.valid? }

      # Take the provisioning profile name into account
      if Sigh.config[:provisioning_name].to_s.length > 0
        filtered = results.select { |p| p.name.strip == Sigh.config[:provisioning_name].strip }
        results = filtered if (filtered || []).count > 0
      end

      return results if Sigh.config[:skip_certificate_verification]


      return results.find_all do |a|
        # Also make sure we have the certificate installed on the local machine
        installed = false
        a.certificates.each do |cert|
          file = Tempfile.new('cert')
          file.write(cert.download_raw)
          file.close
          installed = true if FastlaneCore::CertChecker.is_installed?(file.path)
        end
        installed
      end
    end

    # Create a new profile and return it
    def create_profile!
      cert = certificate_to_use
      bundle_id = Sigh.config[:app_identifier]
      name = Sigh.config[:provisioning_name] || [bundle_id, profile_type.pretty_type].join(' ')

      unless Sigh.config[:skip_fetch_profiles]
        if Spaceship.provisioning_profile.all.find { |p| p.name == name }
          Helper.log.error "The name '#{name}' is already taken, using another one."
          name += " #{Time.now.to_i}"
        end
      end

      Helper.log.info "Creating new provisioning profile for '#{Sigh.config[:app_identifier]}' with name '#{name}'".yellow
      profile = profile_type.create!(name: name,
                                bundle_id: bundle_id,
                              certificate: cert)
      profile
    end


    # Certificate to use based on the current distribution mode
    def certificate_to_use
      if profile_type == Spaceship.provisioning_profile.Development
        certificates = Spaceship.certificate.development.all
      elsif profile_type == Spaceship.provisioning_profile.InHouse
        certificates = Spaceship.certificate.in_house.all
      else
        certificates = Spaceship.certificate.production.all # Ad hoc or App Store
      end

      # Filter them
      certificates = certificates.find_all do |c|
        if Sigh.config[:cert_id]
          next unless (c.id == Sigh.config[:cert_id].strip)
        end

        if Sigh.config[:cert_owner_name]
          next unless (c.owner_name.strip == Sigh.config[:cert_owner_name].strip)
        end

        true
      end

      if certificates.count > 1 and not Sigh.config[:development]
        Helper.log.info "Found more than one code signing identity. Choosing the first one. Check out `sigh --help` to see all available options.".yellow
        Helper.log.info "Available Code Signing Identities for current filters:".green
        certificates.each do |c|
          Helper.log.info ("\t- Name: " + c.owner_name + " - ID: " + c.id + " - Expires: " + c.expires.strftime("%d/%m/%Y")).green
        end
      end

      if certificates.count == 0
        filters = ""
        filters << "Owner Name: '#{Sigh.config[:cert_owner_name]}' " if Sigh.config[:cert_owner_name]
        filters << "Certificate ID: '#{Sigh.config[:cert_id]}' " if Sigh.config[:cert_id]
        Helper.log.info "No certificates for filter: #{filters}".yellow if filters.length > 0
        raise "Could not find a matching code signing identity for #{profile_type}. You can use cert to generate one (https://github.com/fastlane/cert)".red
      end

      return certificates if Sigh.config[:development] # development profiles support multiple certificates
      return certificates.first
    end

    # Downloads and stores the provisioning profile
    def download_profile(profile)
      Helper.log.info "Downloading provisioning profile...".yellow
      profile_name ||= "#{profile.class.pretty_type}_#{Sigh.config[:app_identifier]}.mobileprovision" # default name
      profile_name += '.mobileprovision' unless profile_name.include?'mobileprovision'

      output_path = File.join('/tmp', profile_name)
      dataWritten = File.open(output_path, "wb") do |f|
        f.write(profile.download)
      end

      Helper.log.info "Successfully downloaded provisioning profile...".green
      return output_path
    end
  end
end
