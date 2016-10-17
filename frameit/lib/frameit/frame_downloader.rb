module Frameit
  class FrameDownloader
    FRAME_PATH = '.frameit/devices_frames_2'
    HOST_URL = "https://s3.eu-central-1.amazonaws.com/fastlane-playground/device-frames/"

    def download_frames
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
      return false # TODO
      Dir["#{templates_path}/**/*.png"].count > 0
    end

    def templates_path
      File.join(ENV['HOME'], FRAME_PATH)
    end

    private
    def download_file(path, txt: "file")
      url = File.join(HOST_URL, path)
      UI.message("Downloading #{txt} from '#{url}' ...")
      return Excon.get(url.gsub(' ', '%20'))
    end
  end
end
