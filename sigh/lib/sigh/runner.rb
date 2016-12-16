require 'spaceship'

module Sigh
  class Runner
    attr_accessor :spaceship

    # Uses the spaceship to create or download a provisioning profile
    # returns the path the newly created provisioning profile (in /tmp usually)
    def run
      FastlaneCore::PrintTable.print_values(config: Sigh.config,
                                         hide_keys: [:output_path],
                                             title: "Summary for sigh #{Fastlane::VERSION}")

      UI.message "Starting login with user '#{Sigh.config[:username]}'"
      Spaceship.login(Sigh.config[:username], nil)
      Spaceship.select_team
      UI.message "Successfully logged in"

      profiles = [] if Sigh.config[:skip_fetch_profiles]
      profiles ||= fetch_profiles # download the profile if it's there

      if profiles.count > 0
        UI.success "Found #{profiles.count} matching profile(s)"
        profile = profiles.first

        if Sigh.config[:force]
          if profile_type == Spaceship.provisioning_profile::AppStore or profile_type == Spaceship.provisioning_profile::InHouse
            UI.important "Updating the provisioning profile"
          else
            UI.important "Updating the profile to include all devices"
            profile.devices = Spaceship.device.all_for_profile_type(profile.type)
          end

          profile = profile.update! # assign it, as it's a new profile
        end
      else
        UI.important "No existing profiles found, that match the certificates you have installed locally! Creating a new provisioning profile for you"
        ensure_app_exists!
        profile = create_profile!
      end

      UI.user_error!("Something went wrong fetching the latest profile") unless profile

      if profile_type == Spaceship.provisioning_profile.in_house
        ENV["SIGH_PROFILE_ENTERPRISE"] = "1"
      else
        ENV.delete("SIGH_PROFILE_ENTERPRISE")
      end

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
      UI.message "Fetching profiles..."
      results = profile_type.find_by_bundle_id(Sigh.config[:app_identifier])
      results = results.find_all do |current_profile|
        if current_profile.valid?
          true
        else
          UI.message("Provisioning Profile '#{current_profile.name}' is not valid, skipping this one...")
          false
        end
      end

      # Take the provisioning profile name into account
      if Sigh.config[:provisioning_name].to_s.length > 0
        filtered = results.select { |p| p.name.strip == Sigh.config[:provisioning_name].strip }
        if Sigh.config[:ignore_profiles_with_different_name]
          results = filtered
        elsif (filtered || []).count > 0
          results = filtered
        end
      end

      # Since September 20, 2016 spaceship doesn't distinguish between AdHoc and AppStore profiles
      # any more, since it requires an additional request
      # Instead we only call is_adhoc? on the matching profiles to speed up spaceship

      results = results.find_all do |current_profile|
        if profile_type == Spaceship.provisioning_profile.ad_hoc
          current_profile.is_adhoc?
        elsif profile_type == Spaceship.provisioning_profile.app_store
          !current_profile.is_adhoc?
        else
          true
        end
      end

      return results if Sigh.config[:skip_certificate_verification]

      return results.find_all do |a|
        # Also make sure we have the certificate installed on the local machine
        installed = false
        a.certificates.each do |cert|
          file = Tempfile.new('cert')
          file.write(cert.download_raw)
          file.close
          if FastlaneCore::CertChecker.installed?(file.path)
            installed = true
          else
            UI.message("Certificate for Provisioning Profile '#{a.name}' not available locally: #{cert.id}, skipping this one...")
          end
        end
        installed && a.certificate_valid?
      end
    end

    # Create a new profile and return it
    def create_profile!
      cert = certificate_to_use
      bundle_id = Sigh.config[:app_identifier]
      name = Sigh.config[:provisioning_name] || [bundle_id, profile_type.pretty_type].join(' ')

      unless Sigh.config[:skip_fetch_profiles]
        if Spaceship.provisioning_profile.all.find { |p| p.name == name }
          UI.error "The name '#{name}' is already taken, using another one."
          name += " #{Time.now.to_i}"
        end
      end

      UI.important "Creating new provisioning profile for '#{Sigh.config[:app_identifier]}' with name '#{name}'"
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
          next unless c.id == Sigh.config[:cert_id].strip
        end

        if Sigh.config[:cert_owner_name]
          next unless c.owner_name.strip == Sigh.config[:cert_owner_name].strip
        end

        true
      end

      unless Sigh.config[:skip_certificate_verification]
        certificates = certificates.find_all do |c|
          file = Tempfile.new('cert')
          file.write(c.download_raw)
          file.close

          FastlaneCore::CertChecker.installed?(file.path)
        end
      end

      if certificates.count > 1 and !Sigh.config[:development]
        UI.important "Found more than one code signing identity. Choosing the first one. Check out `sigh --help` to see all available options."
        UI.important "Available Code Signing Identities for current filters:"
        certificates.each do |c|
          str = ["\t- Name:", c.owner_name, "- ID:", c.id + " - Expires", c.expires.strftime("%d/%m/%Y")].join(" ")
          UI.message str.green
        end
      end

      if certificates.count == 0
        filters = ""
        filters << "Owner Name: '#{Sigh.config[:cert_owner_name]}' " if Sigh.config[:cert_owner_name]
        filters << "Certificate ID: '#{Sigh.config[:cert_id]}' " if Sigh.config[:cert_id]
        UI.important "No certificates for filter: #{filters}" if filters.length > 0
        message = "Could not find a matching code signing identity for type '#{profile_type.to_s.split(':').last}'. "
        message += "It is recommended to use match to manage code signing for you, more information on https://codesigning.guide."
        message += "If you don't want to do so, you can also use cert to generate a new one: https://fastlane.tools/cert"
        UI.user_error!(message)
      end

      return certificates if Sigh.config[:development] # development profiles support multiple certificates
      return certificates.first
    end

    # Downloads and stores the provisioning profile
    def download_profile(profile)
      UI.important "Downloading provisioning profile..."
      profile_name ||= "#{profile_type.pretty_type}_#{Sigh.config[:app_identifier]}.mobileprovision" # default name
      profile_name += '.mobileprovision' unless profile_name.include? 'mobileprovision'

      tmp_path = Dir.mktmpdir("profile_download")
      output_path = File.join(tmp_path, profile_name)
      File.open(output_path, "wb") do |f|
        f.write(profile.download)
      end

      UI.success "Successfully downloaded provisioning profile..."
      return output_path
    end

    # Makes sure the current App ID exists. If not, it will show an appropriate error message
    def ensure_app_exists!
      return if Spaceship::App.find(Sigh.config[:app_identifier])
      print_produce_command(Sigh.config)
      UI.user_error!("Could not find App with App Identifier '#{Sigh.config[:app_identifier]}'")
    end

    def print_produce_command(config)
      UI.message ""
      UI.message "==========================================".yellow
      UI.message "Could not find App ID with bundle identifier '#{config[:app_identifier]}'"
      UI.message "You can easily generate a new App ID on the Developer Portal using 'produce':"
      UI.message ""
      UI.message "produce -u #{config[:username]} -a #{config[:app_identifier]} --skip_itc".yellow
      UI.message ""
      UI.message "You will be asked for any missing information, like the full name of your app"
      UI.message "If the app should also be created on iTunes Connect, remove the " + "--skip_itc".yellow + " from the command above"
      UI.message "==========================================".yellow
      UI.message ""
    end
  end
end
