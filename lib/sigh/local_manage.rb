module Sigh
  class LocalManage
    LIST = "list"
    CLEANUP = "cleanup"

    def self.start(options, args)
      command, clean_expired, clean_pattern = get_inputs(options, args)
      if command == LIST
        list_profiles
      elsif command == CLEANUP
        cleanup_profiles(clean_expired, clean_pattern)
      end
    end

    def self.install_profile(profile)
      Helper.log.info "Installing provisioning profile..."
      profile_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles/"
      profile_filename = ENV["SIGH_UDID"] + ".mobileprovision"
      destination = profile_path + profile_filename

      # If the directory doesn't exist, make it first
      unless File.directory?(profile_path)
        FileUtils.mkdir_p(profile_path)
      end

      # copy to Xcode provisioning profile directory
      FileUtils.copy profile, destination

      if File.exists? destination
        Helper.log.info "Profile installed at \"#{destination}\""
      else
        raise "Failed installation of provisioning profile at location: #{destination}".red
      end
    end

    def self.get_inputs(options, args)
      clean_expired = options.clean_expired
      clean_pattern = /#{options.clean_pattern}/ if options.clean_pattern
      command = (clean_expired != nil || clean_pattern != nil) ? CLEANUP : LIST
      return command, clean_expired, clean_pattern
    end

    def self.list_profiles
      profiles = load_profiles

      now = DateTime.now
      soon = (Date.today + 30).to_datetime

      profiles_valid = profiles.select { |profile| profile["ExpirationDate"] > now && profile["ExpirationDate"] > soon }
      if profiles_valid.count > 0
        Helper.log.info "Provisioning profiles installed"
        Helper.log.info "Valid:"
        profiles_valid.each do |profile|
          Helper.log.info profile["Name"].green
        end
      end

      profiles_soon = profiles.select { |profile| profile["ExpirationDate"] > now && profile["ExpirationDate"] < soon }
      if profiles_soon.count > 0
        Helper.log.info ""
        Helper.log.info "Expiring within 30 day:"
        profiles_soon.each do |profile|
          Helper.log.info profile["Name"].yellow
        end
      end
      
      profiles_expired = profiles.select { |profile| profile["ExpirationDate"] < now }
      if profiles_expired.count > 0
        Helper.log.info ""
        Helper.log.info "Expired:"
        profiles_expired.each do |profile|
          Helper.log.info profile["Name"].red
        end
      end
      
      Helper.log.info ""
      Helper.log.info "Summary"
      Helper.log.info "#{profiles.count} installed profiles"
      Helper.log.info "#{profiles_expired.count} are expired".red
      Helper.log.info "#{profiles_soon.count} are valid but will expire within 30 days".yellow
      Helper.log.info "#{profiles_valid.count} are valid".green

      Helper.log.info "You can remove all expired profiles using `sigh manage -e`" if profiles_expired.count > 0
    end

    def self.cleanup_profiles(expired = false, pattern = nil)
      now = DateTime.now

      profiles = load_profiles.select { |profile| (expired && profile["ExpirationDate"] < now) || (pattern != nil && profile["Name"] =~ pattern) }

      Helper.log.info "The following provisioning profiles are either expired or matches your pattern:"
      profiles.each do |profile|
        Helper.log.info profile["Name"].red
      end

      if agree("Delete these provisioning profiles #{profiles.length}? (y/n)  ", true)
        profiles.each do |profile|
          File.delete profile["Path"]
        end
        Helper.log.info "\n\nDeleted #{profiles.length} profiles".green
      end
    end

    def self.load_profiles
      Helper.log.info "Loading Provisioning profiles from ~/Library/MobileDevice/Provisioning Profiles/"
      profiles_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles/*.mobileprovision"
      profile_paths = Dir[profiles_path]

      profiles = []
      profile_paths.each do |profile_path|
        profile = Plist::parse_xml(`security cms -D -i '#{profile_path}'`)
        profile['Path'] = profile_path
        profiles << profile
      end

      profiles = profiles.sort_by {|profile| profile["Name"].downcase}

      return profiles
    end
  end
end