module Sigh
  class DownloadAll
    # Download all valid provisioning profiles
    def download_all
      UI.message "Starting login with user '#{Sigh.config[:username]}'"
      Spaceship.login(Sigh.config[:username], nil)
      Spaceship.select_team
      UI.message "Successfully logged in"

      Spaceship.provisioning_profile.all.each do |profile|
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

      type_name = profile.class.pretty_type
      type_name = "AdHoc" if profile.is_adhoc?

      profile_name = "#{type_name}_#{profile.app.bundle_id}.mobileprovision" # default name

      output_path = File.join(Sigh.config[:output_path], profile_name)
      File.open(output_path, "wb") do |f|
        f.write(profile.download)
      end

      Manager.install_profile(output_path) unless Sigh.config[:skip_install]
    end
  end
end
