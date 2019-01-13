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

      Spaceship.provisioning_profile.all(xcode: download_xcode_profiles).each do |profile|
        if profile.valid?
          UI.message("Downloading profile '#{profile.name}'...")
          download_profile(profile)
        else
          UI.important("Skipping invalid/expired profile '#{profile.name}'")
        end
      end

      if download_xcode_profiles
        UI.message("This run also included all Xcode managed provisioning profiles, as you used the `--download_xcode_profiles` flag")
      else
        UI.message("All Xcode managed provisioning profiles were ignored on this, to include them use the `--download_xcode_profiles` flag")
      end
    end

    def download_profile(profile)
      FileUtils.mkdir_p(Sigh.config[:output_path])

      type_name = profile.class.pretty_type
      profile_name = "#{type_name}_#{profile.uuid}_#{profile.app.bundle_id}.mobileprovision" # default name

      output_path = File.join(Sigh.config[:output_path], profile_name)
      File.open(output_path, "wb") do |f|
        f.write(profile.download)
      end

      Manager.install_profile(output_path) unless Sigh.config[:skip_install]
    end
  end
end
