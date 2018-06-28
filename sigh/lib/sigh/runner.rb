require 'spaceship'

require 'fastlane_core/print_table'
require 'fastlane_core/cert_checker'
require_relative 'module'

module Sigh
  class Runner
    attr_accessor :spaceship

    # Uses the spaceship to create or download a provisioning profile
    # returns the path the newly created provisioning profile (in /tmp usually)
    def run
      FastlaneCore::PrintTable.print_values(config: Sigh.config,
                                         hide_keys: [:output_path],
                                             title: "Summary for sigh #{Fastlane::VERSION}")

      UI.message("Starting login with user '#{Sigh.config[:username]}'")
      Spaceship.login(Sigh.config[:username], nil)
      Spaceship.select_team
      UI.message("Successfully logged in")

      profiles = [] if Sigh.config[:skip_fetch_profiles]
      profiles ||= fetch_profiles # download the profile if it's there

      if profiles.count > 0
        UI.success("Found #{profiles.count} matching profile(s)")
        profile = profiles.first

        if Sigh.config[:force]
          # Recreating the profile ensures it has all of the requested properties (cert, name, etc.)
          UI.important("Recreating the profile")
          profile.delete!
          profile = create_profile!
        end
      else
        UI.user_error!("No matching provisioning profile found and can not create a new one because you enabled `readonly`") if Sigh.config[:readonly]
        UI.important("No existing profiles found, that match the certificates you have installed locally! Creating a new provisioning profile for you")
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
      UI.message("Fetching profiles...")
      results = profile_type.find_by_bundle_id(bundle_id: Sigh.config[:app_identifier],
                                                     mac: Sigh.config[:platform].to_s == 'macos',
                                            sub_platform: Sigh.config[:platform].to_s == 'tvos' ? 'tvOS' : nil)
      results = results.find_all do |current_profile|
        if current_profile.valid? || Sigh.config[:force]
          true
        else
          UI.message("Provisioning Profile '#{current_profile.name}' is not valid, skipping this one...")
          false
        end
      end

      # Take the provisioning profile name into account
      results = filter_profiles_by_name(results) if Sigh.config[:provisioning_name].to_s.length > 0

      # Since September 20, 2016 spaceship doesn't distinguish between AdHoc and AppStore profiles
      # any more, since it requires an additional request
      # Instead we only call is_adhoc? on the matching profiles to speed up spaceship

      results = filter_profiles_for_adhoc_or_app_store(results)

      return results if Sigh.config[:skip_certificate_verification]

      UI.message("Verifying certificates...")
      return results.find_all do |current_profile|
        installed = false

        # Attempts to download all certificates from this profile
        # for checking if they are installed.
        # `cert.download_raw` can fail if the user is a
        # "member" and not an a "admin"
        raw_certs = current_profile.certificates.map do |cert|
          begin
            raw_cert = cert.download_raw
          rescue => error
            UI.important("Cannot download cert #{cert.id} - #{error.message}")
            raw_cert = nil
          end
          { downloaded: raw_cert, cert: cert }
        end

        # Makes sure we have the certificate installed on the local machine
        raw_certs.each do |current_cert|
          # Skip certificates that failed to download
          next unless current_cert[:downloaded]
          file = Tempfile.new('cert')
          file.write(current_cert[:downloaded])
          file.close
          if FastlaneCore::CertChecker.installed?(file.path)
            installed = true
          else
            UI.message("Certificate for Provisioning Profile '#{current_profile.name}' not available locally: #{current_cert[:cert].id}, skipping this one...")
          end
        end
        installed && current_profile.certificate_valid?
      end
    end

    # Create a new profile and return it
    def create_profile!
      cert = certificate_to_use
      bundle_id = Sigh.config[:app_identifier]
      name = Sigh.config[:provisioning_name] || [bundle_id, profile_type.pretty_type].join(' ')

      unless Sigh.config[:skip_fetch_profiles]
        if Spaceship.provisioning_profile.all.find { |p| p.name == name }
          UI.error("The name '#{name}' is already taken, using another one.")
          name += " #{Time.now.to_i}"
        end
      end

      UI.important("Creating new provisioning profile for '#{Sigh.config[:app_identifier]}' with name '#{name}' for '#{Sigh.config[:platform]}' platform")
      profile = profile_type.create!(name: name,
                                bundle_id: bundle_id,
                              certificate: cert,
                                      mac: Sigh.config[:platform].to_s == 'macos',
                             sub_platform: Sigh.config[:platform].to_s == 'tvos' ? 'tvOS' : nil,
                            template_name: Sigh.config[:template_name])
      profile
    end

    def filter_profiles_by_name(profiles)
      filtered = profiles.select { |p| p.name.strip == Sigh.config[:provisioning_name].strip }
      if Sigh.config[:ignore_profiles_with_different_name]
        profiles = filtered
      elsif (filtered || []).count > 0
        profiles = filtered
      end
      profiles
    end

    def filter_profiles_for_adhoc_or_app_store(profiles)
      profiles.find_all do |current_profile|
        if profile_type == Spaceship.provisioning_profile.ad_hoc
          current_profile.is_adhoc?
        elsif profile_type == Spaceship.provisioning_profile.app_store
          !current_profile.is_adhoc?
        else
          true
        end
      end
    end

    def certificates_for_profile_and_platform
      case Sigh.config[:platform].to_s
      when 'ios', 'tvos'
        if profile_type == Spaceship.provisioning_profile.Development
          certificates = Spaceship.certificate.development.all
        elsif profile_type == Spaceship.provisioning_profile.InHouse
          certificates = Spaceship.certificate.in_house.all
        # handles case where the desired certificate type is adhoc but the account is an enterprise account
        # the apple dev portal api has a weird quirk in it where if you query for distribution certificates
        # for enterprise accounts, you get nothing back even if they exist.
        elsif profile_type == Spaceship.provisioning_profile.AdHoc && Spaceship.client && Spaceship.client.in_house?
          certificates = Spaceship.certificate.in_house.all
        else
          certificates = Spaceship.certificate.production.all # Ad hoc or App Store
        end

      when 'macos'
        if profile_type == Spaceship.provisioning_profile.Development
          certificates = Spaceship.certificate.mac_development.all
        elsif profile_type == Spaceship.provisioning_profile.AppStore
          certificates = Spaceship.certificate.mac_app_distribution.all
        elsif profile_type == Spaceship.provisioning_profile.Direct
          certificates = Spaceship.certificate.developer_id_application.all
        else
          certificates = Spaceship.certificate.mac_app_distribution.all
        end
      end

      certificates
    end

    # Certificate to use based on the current distribution mode
    def certificate_to_use
      certificates = certificates_for_profile_and_platform

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

      if certificates.count > 1 && !Sigh.config[:development]
        UI.important("Found more than one code signing identity. Choosing the first one. Check out `fastlane sigh --help` to see all available options.")
        UI.important("Available Code Signing Identities for current filters:")
        certificates.each do |c|
          str = ["\t- Name:", c.owner_name, "- ID:", c.id + " - Expires", c.expires.strftime("%d/%m/%Y")].join(" ")
          UI.message(str.green)
        end
      end

      if certificates.count == 0
        filters = ""
        filters << "Owner Name: '#{Sigh.config[:cert_owner_name]}' " if Sigh.config[:cert_owner_name]
        filters << "Certificate ID: '#{Sigh.config[:cert_id]}' " if Sigh.config[:cert_id]
        UI.important("No certificates for filter: #{filters}") if filters.length > 0
        message = "Could not find a matching code signing identity for type '#{profile_type.to_s.split(':').last}'. "
        message += "It is recommended to use match to manage code signing for you, more information on https://codesigning.guide. "
        message += "If you don't want to do so, you can also use cert to generate a new one: https://fastlane.tools/cert"
        UI.user_error!(message)
      end

      return certificates if Sigh.config[:development] # development profiles support multiple certificates
      return certificates.first
    end

    # Downloads and stores the provisioning profile
    def download_profile(profile)
      UI.important("Downloading provisioning profile...")
      profile_name ||= "#{profile_type.pretty_type}_#{Sigh.config[:app_identifier]}"

      if Sigh.config[:platform].to_s == 'tvos'
        profile_name += "_tvos"
      end

      profile_name += '.mobileprovision'

      tmp_path = Dir.mktmpdir("profile_download")
      output_path = File.join(tmp_path, profile_name)
      File.open(output_path, "wb") do |f|
        f.write(profile.download)
      end

      UI.success("Successfully downloaded provisioning profile...")
      return output_path
    end

    # Makes sure the current App ID exists. If not, it will show an appropriate error message
    def ensure_app_exists!
      return if Spaceship::App.find(Sigh.config[:app_identifier], mac: Sigh.config[:platform].to_s == 'macos')
      print_produce_command(Sigh.config)
      UI.user_error!("Could not find App with App Identifier '#{Sigh.config[:app_identifier]}'")
    end

    def print_produce_command(config)
      UI.message("")
      UI.message("==========================================".yellow)
      UI.message("Could not find App ID with bundle identifier '#{config[:app_identifier]}'")
      UI.message("You can easily generate a new App ID on the Developer Portal using 'produce':")
      UI.message("")
      UI.message("fastlane produce -u #{config[:username]} -a #{config[:app_identifier]} --skip_itc".yellow)
      UI.message("")
      UI.message("You will be asked for any missing information, like the full name of your app")
      UI.message("If the app should also be created on App Store Connect, remove the " + "--skip_itc".yellow + " from the command above")
      UI.message("==========================================".yellow)
      UI.message("")
    end
  end
end
