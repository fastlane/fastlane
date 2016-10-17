module Frameit
  class FrameDownloader
    FRAME_PATH = '.frameit/devices_frames_2'
    HOST_URL = "https://s3.eu-central-1.amazonaws.com/fastlane-playground/device-frames/"

    def download_frames
      print_disclaimer

      require 'json'
      require 'fileutils'

      UI.message("Downloading device frames...")
      FileUtils.mkdir_p(templates_path)

      files = JSON.parse(download_file("files.json").body)
      files.each_with_index do |current, index|
        content = download_file(current, txt: "#{index + 1} of #{files.count} files")
        File.write(File.join(templates_path, current), content.body)
      end
      File.write(File.join(templates_path, "version.txt"), download_file("version.txt").body)
      File.write(File.join(templates_path, "offsets.json"), download_file("offsets.json").body)

      UI.success("Successfully downloaded all required image assets")
    end

    def frames_exist?
      Dir["#{templates_path}/*.png"].count > 0 && File.read(File.join(templates_path, "version.txt")).to_i > 0
    end

    def templates_path
      File.join(ENV['HOME'], FRAME_PATH)
    end

    def print_disclaimer
      UI.header "Device frames disclaimer"
      UI.important "All used device frames are available via Facebook Design: http://facebook.design/devices"
      UI.message "----------------------------------------"
      UI.message "While Facebook has redrawn and shares these assets for the benefit of the design community, Facebook does not own any of the underlying product or user interface designs. " 
      UI.message "By accessing these assets, you agree to obtain all necessary permissions from the underlying rights holders and/or adhere to any applicable brand use guidelines before using them. "
      UI.message "Facebook disclaims all express or implied warranties with respect to these assets, including non-infringement of intellectual property rights."
      UI.message "----------------------------------------"
    end

    private
    def download_file(path, txt: "file")
      url = File.join(HOST_URL, path)
      UI.message("Downloading #{txt} from '#{url}' ...")
      return Excon.get(url.gsub(' ', '%20'))
    end
  end
end
