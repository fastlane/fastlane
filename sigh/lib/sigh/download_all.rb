require 'spaceship'

require_relative 'manager'
require_relative 'module'

module Sigh
  class DownloadAll
    # Download all valid provisioning profiles
    def download_all(download_xcode_profiles: false)
      UI.message("Starting login with user '#{Sigh.config[:username]}'")
      Spaceship.login(Sigh.config[:username], nil)
      Spaceship.select_team
      UI.message("Successfully logged in")

      case Sigh.config[:platform].to_s
      when 'ios'
        download_profiles(Spaceship.provisioning_profile.all(xcode: download_xcode_profiles))
        xcode_profiles_downloaded?(xcode: download_xcode_profiles, supported: true)
      when 'macos'
        download_profiles(Spaceship.provisioning_profile.all(mac: true, xcode: download_xcode_profiles))
        xcode_profiles_downloaded?(xcode: download_xcode_profiles, supported: true)
      when 'tvos'
        download_profiles(Spaceship.provisioning_profile.all_tvos)
        xcode_profiles_downloaded?(xcode: download_xcode_profiles, supported: false)
      end
    end

    # @param xcode [Bool] Whether or not the user passed the download_xcode_profiles flag
    # @param supported [Bool] Whether or not this platform supports downloading xcode profiles at all
    def xcode_profiles_downloaded?(xcode: false, supported: false)
      if supported
        if xcode
          UI.message("This run also included all Xcode managed provisioning profiles, as you used the `--download_xcode_profiles` flag")
        elsif !xcode
          UI.message("All Xcode managed provisioning profiles were ignored on this, to include them use the `--download_xcode_profiles` flag")
        end

      elsif !supported
        if xcode
          UI.important("Downloading Xcode managed profiles is not supported for platform #{Sigh.config[:platform]}")
          return
        end
      end
    end

    # @param profiles [Array] Array of all the provisioning profiles we want to download
    def download_profiles(profiles)
      UI.important("No profiles available for download") if profiles.empty?

      profiles.each do |profile|
        if profile.valid?
          UI.message("Downloading profile '#{profile.name}'...")
          download_profile(profile)
        else
          UI.important("Skipping invalid/expired profile '#{profile.name}'")
        end
      end
    end

    # @param profile [ProvisioningProfile] A profile we plan to download and store
    def download_profile(profile)
      FileUtils.mkdir_p(Sigh.config[:output_path])

      type_name = profile.class.pretty_type
      profile_name = "#{type_name}_#{profile.uuid}_#{profile.app.bundle_id}"

      if Sigh.config[:platform].to_s == 'tvos'
        profile_name += "_tvos"
      end

      if Sigh.config[:platform].to_s == 'macos'
        profile_name += '.provisionprofile'
      else
        profile_name += '.mobileprovision'
      end

      output_path = File.join(Sigh.config[:output_path], profile_name)
      File.open(output_path, "wb") do |f|
        f.write(profile.download)
      end

      Manager.install_profile(output_path) unless Sigh.config[:skip_install]
    end
  end
end
