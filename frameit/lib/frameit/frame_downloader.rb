module Frameit
  class FrameDownloader
    FRAME_PATH = '.frameit/devices_frames_2'

    def run
      self.setup_frames
    end

    def setup_frames
      UI.success "TODO: IMPLEMENT DOWNLOAD HERE"
      STDIN.gets
    end

    def frames_exist?
      Dir["#{templates_path}/**/*.png"].count > 0
    end

    def templates_path
      "#{ENV['HOME']}/#{FRAME_PATH}"
    end
  end
end
