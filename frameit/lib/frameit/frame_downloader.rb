require 'fastlane_core/module'

require_relative 'module'

module Frameit
  class FrameDownloader
    HOST_URL = "https://fastlane.github.io/frameit-frames"

    def download_frames
      print_disclaimer

      require 'json'
      require 'fileutils'

      UI.message("Downloading device frames to '#{templates_path}'")
      FileUtils.mkdir_p(templates_path)

      frames_version = download_file("version.txt")
      UI.important("Using frame version '#{frames_version}', you can optionally lock that version in your Framefile.json using `device_frame_version`")

      files = JSON.parse(download_file("files.json"))
      files.each_with_index do |current, index|
        content = download_file(current, txt: "#{index + 1} of #{files.count} files")
        File.binwrite(File.join(templates_path, current), content)
      end
      File.write(File.join(templates_path, "offsets.json"), download_file("offsets.json"))

      # Write the version.txt at the very end to properly resume downloads
      # if it's interrupted
      File.write(File.join(templates_path, "version.txt"), frames_version)

      UI.success("Successfully downloaded all required image assets")
    end

    def frames_exist?(version: "latest")
      version_path = File.join(templates_path, "version.txt")
      version = File.read(version_path) if File.exist?(version_path)
      Dir["#{templates_path}/*.png"].count > 0 && version.to_i > 0
    end

    def self.templates_path
      # Previously ~/.frameit/device_frames_2/x
      legacy_path = File.join(ENV['HOME'], ".frameit/devices_frames_2", Frameit.frames_version)
      return legacy_path if File.directory?(legacy_path)

      # New path, being ~/.fastlane/frameit/x
      return File.join(FastlaneCore.fastlane_user_dir, "frameit", Frameit.frames_version)
    end

    def templates_path
      self.class.templates_path
    end

    def print_disclaimer
      UI.header("Device frames disclaimer")
      UI.important("All used device frames are available via Facebook Design: https://design.facebook.com/toolsandresources/devices/")
      UI.message("----------------------------------------")
      UI.message("While Facebook has redrawn and shares these assets for the benefit")
      UI.message("of the design community, Facebook does not own any of the underlying")
      UI.message("product or user interface designs.")
      UI.message("By accessing these assets, you agree to obtain all necessary permissions")
      UI.message("from the underlying rights holders and/or adhere to any applicable brand")
      UI.message("use guidelines before using them.")
      UI.message("Facebook disclaims all express or implied warranties with respect to these assets, including")
      UI.message("non-infringement of intellectual property rights.")
      UI.message("----------------------------------------")
    end

    private

    def download_file(path, txt: "file")
      require 'uri'
      require 'excon'
      require 'addressable/uri'

      url = File.join(HOST_URL, Frameit.frames_version, Addressable::URI.encode(path))
      UI.message("Downloading #{txt} from '#{url}' ...")
      body = Excon.get(url).body
      raise body if body.include?("<Error>")
      return body
    rescue => ex
      UI.error(ex)
      UI.user_error!("Error accessing URL '#{url}'")
    end
  end
end
