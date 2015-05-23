require 'spaceship'

module Sigh
  class Runner
    attr_accessor :spaceship

    # Uses the spaceship to create or download a provisioning profile
    # returns the path the newly created provisioning profile (in /tmp usually)
    def run
      spaceship = Spaceship.login(Sigh.config[:username], nil)
      # spaceship.UI.select_team # TODO: FIX
      
      profiles = fetch_profiles # download the profile if it's there
      Helper.log.info "Found #{profiles.count} profiles, using the first one".yellow if profiles.count > 1
      profile = profiles.first
      
      path = store_profile(profile)
      store_provisioning_id_in_environment(path)

      return path
    end

    # The kind of provisioning profile we're interested in
    def profile_type
      return @profile_type if @profile_type

      @profile_type = Spaceship::ProvisioningProfile::AppStore
      @profile_type = Spaceship::ProvisioningProfile::AdHoc if Sigh.config[:adhoc]
      @profile_type = Spaceship::ProvisioningProfile::Development if Sigh.config[:development]

      @profile_type
    end

    # Fetches a profile matching the user's search requirements
    def fetch_profiles
      profile_type.all.select do |profile|
        
        # Does the app identifier match
        next unless (profile.app.bundle_id == Sigh.config[:app_identifier])

        true
      end
    end

    # Downloads and stores the provisioning profile
    def store_profile(profile)
      profile_name ||= "#{profile.class.type}_#{Sigh.config[:app_identifier]}.mobileprovision" # default name
      profile_name += '.mobileprovision' unless profile_name.include?'mobileprovision'

      output_path = File.join('/tmp', profile_name)
      dataWritten = File.open(output_path, "wb") do |f|
        f.write(profile.download)
      end

      output_path
    end

    # Store the profile ID into the environment
    def store_provisioning_id_in_environment(path)
      require 'sigh/profile_analyser'
      udid = Sigh::ProfileAnalyser.run(path)
      ENV["SIGH_UDID"] = udid if udid
    end
  end
end