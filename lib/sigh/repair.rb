module Sigh
  class Repair
    def repair_all
      Helper.log.info "Starting login"
      Spaceship.login(Sigh.config[:username], nil)
      Spaceship.select_team
      Helper.log.info "Successfully logged in"

      # Select all 'Invalid' or 'Expired' provisioning profiles
      broken_profiles = Spaceship.provisioning_profile.all.find_all do |profile| 
        (profile.status == "Invalid" or profile.status == "Expired")
      end

      if broken_profiles.count == 0
        Helper.log.info "All provisioning profiles are valid, nothing to do".green
        return
      end

      Helper.log.info "Going to repair #{broken_profiles.count} provisioning profiles".green

      # Iterate over all broken profiles and repair them
      broken_profiles.each do |profile|
        Helper.log.info "Repairing profile '#{profile.name}'..."
        profile.repair! # yes, that's all you need to repair a profile
      end

      Helper.log.info "Successfully repaired #{broken_profiles.count} provisioning profiles".green
    end
  end
end