module Sigh
  class DownloadAll
    # Download all valid provisioning profiles
    def download_all
      UI.message "Starting login with user '#{Sigh.config[:username]}'"
      Spaceship.login(Sigh.config[:username], nil)
      Spaceship.select_team
      UI.message "Successfully logged in"

      Spaceship.provisioning_profile.all(include_invalid_profiles=false).each do |profile|

        if profile.valid?
          UI.message "Downloading profile '#{profile.name}'..."
          download_profile(profile)
        else
          UI.important "Skipping invalid/expired profile '#{profile.name}'"
        end
      end
    end

    def download_profile(profile)
      FileUtils.mkdir_p(Sigh.config[:output_path])

      if Sigh.config[:use_apple_developer_portal_profile_names]
        profile_name = "#{profile.name}.mobileprovision"
      else
        profile_name = "#{profile.class.pretty_type}_#{profile.app.bundle_id}.mobileprovision"
      end

      output_path = File.join(Sigh.config[:output_path], profile_name)
      File.open(output_path, "wb") do |f|
        f.write(profile.download)
      end

      Manager.install_profile(output_path) unless Sigh.config[:skip_install]
    end
  end
end
