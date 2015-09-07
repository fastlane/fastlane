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
      udid = FastlaneCore::ProvisioningProfile.uuid(profile)
      ENV["SIGH_UDID"] = udid if udid

      FastlaneCore::ProvisioningProfile.install(profile)
    end
  end
end
