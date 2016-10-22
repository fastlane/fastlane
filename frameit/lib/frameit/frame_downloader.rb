module Frameit
  class FrameDownloader
    FRAME_PATH = '.frameit/devices_frames_2'
    HOST_URL = "https://fastlane.github.io/frameit-frames"

    def download_frames
      print_disclaimer

      require 'json'
      require 'fileutils'

      UI.message("Downloading device frames...")
      FileUtils.mkdir_p(templates_path)

      frames_version = download_file("version.txt")
      File.write(File.join(templates_path, "version.txt"), frames_version)
      UI.important("Using frame version '#{frames_version}', you can optionally lock that version in your Framefile.json using `device_frame_version`")

      files = JSON.parse(download_file("files.json"))
      files.each_with_index do |current, index|
        content = download_file(current, txt: "#{index + 1} of #{files.count} files")
        File.write(File.join(templates_path, current), content)
      end
      File.write(File.join(templates_path, "offsets.json"), download_file("offsets.json"))

      UI.success("Successfully downloaded all required image assets")
    end

    def frames_exist?(version: "latest")
      Dir["#{templates_path}/*.png"].count > 0 && File.read(File.join(templates_path, "version.txt")).to_i > 0
    end

    def self.templates_path
      File.join(ENV['HOME'], FRAME_PATH, Frameit.frames_version)
    end

    def templates_path
      self.class.templates_path
    end

    def print_disclaimer
      UI.header "Device frames disclaimer"
      UI.important "All used device frames are available via Facebook Design: http://facebook.design/devices"
      UI.message "----------------------------------------"
      UI.message "While Facebook has redrawn and shares these assets for the benefit"
      UI.message "of the design community, Facebook does not own any of the underlying"
      UI.message "product or user interface designs."
      UI.message "By accessing these assets, you agree to obtain all necessary permissions"
      UI.message "from the underlying rights holders and/or adhere to any applicable brand"
      UI.message "use guidelines before using them."
      UI.message "Facebook disclaims all express or implied warranties with respect to these assets, including"
      UI.message "non-infringement of intellectual property rights."
      UI.message "----------------------------------------"
    end

    private

    def download_file(path, txt: "file")
      require 'uri'

      url = File.join(HOST_URL, Frameit.frames_version, URI.escape(path))
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
