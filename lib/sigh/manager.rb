require 'plist'
require 'sigh/spaceship/runner'

module Sigh
  class Manager
    def self.start
      path = Sigh::Runner.new.run

      return nil unless path

      if Sigh.config[:filename]
        file_name = Sigh.config[:filename]
      else
        file_name = File.basename(path)
      end

      output = File.join(Sigh.config[:output_path].gsub("~", ENV["HOME"]), file_name)
      (FileUtils.mv(path, output) rescue nil) # in case it already exists

      install_profile(output) unless Sigh.config[:skip_install]

      puts output.green

      return File.expand_path(output)
    end

    def self.download_all
      require 'sigh/download_all'
      DownloadAll.new.download_all
    end

    def self.install_profile(profile)
      Helper.log.info "Installing provisioning profile..."

      require 'sigh/profile_analyser'
      udid = Sigh::ProfileAnalyser.run(profile)
      ENV["SIGH_UDID"] = udid if udid

      profile_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles/"
      profile_filename = ENV["SIGH_UDID"] + ".mobileprovision"
      destination = profile_path + profile_filename

      # If the directory doesn't exist, make it first
      unless File.directory?(profile_path)
        FileUtils.mkdir_p(profile_path)
      end

      # copy to Xcode provisioning profile directory
      (FileUtils.copy profile, destination rescue nil) # if the directory doesn't exist yet

      if File.exists? destination
        Helper.log.info "Profile successfully installed".green
      else
        raise "Failed installation of provisioning profile at location: #{destination}".red
      end
    end
  end
end
