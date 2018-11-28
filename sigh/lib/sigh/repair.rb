require 'spaceship'

require_relative 'module'

module Sigh
  class Repair
    def repair_all
      UI.message("Starting login with user '#{Sigh.config[:username]}'")
      Spaceship.login(Sigh.config[:username], nil)
      Spaceship.select_team
      UI.message("Successfully logged in")

      # Select all 'Invalid' or 'Expired' provisioning profiles
      broken_profiles = Spaceship.provisioning_profile.all.find_all do |profile|
        (profile.status == "Invalid" or profile.status == "Expired")
      end

      if broken_profiles.count == 0
        UI.success("All provisioning profiles are valid, nothing to do")
        return
      end

      UI.success("Going to repair #{broken_profiles.count} provisioning profiles")

      # Iterate over all broken profiles and repair them
      broken_profiles.each do |profile|
        UI.message("Repairing profile '#{profile.name}'...")
        profile.repair! # yes, that's all you need to repair a profile
      end

      UI.success("Successfully repaired #{broken_profiles.count} provisioning profiles")
    end
  end
end
