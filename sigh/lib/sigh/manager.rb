require 'plist'
require 'sigh/runner'

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

      FileUtils.mkdir_p(Sigh.config[:output_path])
      output = File.join(File.expand_path(Sigh.config[:output_path]), file_name)
      begin
        FileUtils.mv(path, output)
      rescue
        # in case it already exists
      end

      install_profile(output) unless Sigh.config[:skip_install]

      puts output.green

      return File.expand_path(output)
    end

    def self.download_all
      require 'sigh/download_all'
      DownloadAll.new.download_all
    end

    def self.install_profile(profile)
      uuid = FastlaneCore::ProvisioningProfile.uuid(profile)
      ENV["SIGH_UDID"] = ENV["SIGH_UUID"] = uuid if uuid

      FastlaneCore::ProvisioningProfile.install(profile)
    end
  end
end
