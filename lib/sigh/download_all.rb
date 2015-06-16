module Sigh
  class DownloadAll
    # Download all valid provisioning profiles
    def download_all
      Helper.log.info "Starting login"
      Spaceship.login(Sigh.config[:username], nil)
      Spaceship.select_team
      Helper.log.info "Successfully logged in"

      Spaceship.provisioning_profile.all.each do |profile|
        if profile.valid?
          Helper.log.info "Downloading profile '#{profile.name}'...".green
          download_profile(profile)
        else
          Helper.log.info "Skipping invalid/expired profile '#{profile.name}'".yellow
        end
      end
    end

    def download_profile(profile)
      output = Sigh.config[:output_path] || "/tmp"

      profile_name = "#{profile.class.pretty_type}_#{profile.app.bundle_id}.mobileprovision" # default name

      output_path = File.join(output, profile_name)
      dataWritten = File.open(output_path, "wb") do |f|
        f.write(profile.download)
      end

      Manager.install_profile(output_path) unless Sigh.config[:skip_install]
    end
  end
end