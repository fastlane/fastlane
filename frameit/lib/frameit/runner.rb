require 'fastimage'

require_relative 'frame_downloader'
require_relative 'module'
require_relative 'screenshot'
require_relative 'device_types'

module Frameit
  class Runner
    def initialize
      downloader = FrameDownloader.new
      unless downloader.frames_exist?
        downloader.download_frames
      end
    end

    def run(path, color = nil)
      unless color
        color = Frameit::Color::BLACK
        color = Frameit::Color::SILVER if Frameit.config[:white] || Frameit.config[:silver]
        color = Frameit::Color::GOLD if Frameit.config[:gold]
        color = Frameit::Color::ROSE_GOLD if Frameit.config[:rose_gold]
      end

      screenshots = Dir.glob("#{path}/**/*.{png,PNG}").uniq # uniq because thanks to {png,PNG} there are duplicates

      if screenshots.count > 0
        screenshots.each do |full_path|
          next if full_path.include?("_framed.png")
          next if full_path.include?(".itmsp/") # a package file, we don't want to modify that
          next if full_path.include?("device_frames/") # these are the device frames the user is using
          device = full_path.rpartition('/').last.partition('-').first # extract device name
          if device.downcase.include?("watch")
            UI.error("Apple Watch screenshots are not framed: '#{full_path}'")
            next # we don't care about watches right now
          end

          begin
            screenshot = Screenshot.new(full_path, color)
            if screenshot.mac?
              editor = MacEditor.new(screenshot)
            else
              editor = Editor.new(screenshot, Frameit.config[:debug_mode])
            end
            if editor.should_skip?
              UI.message("Skipping framing of screenshot #{screenshot.path}.  No title provided in your Framefile.json or title.strings.")
            else
              Helper.show_loading_indicator("Framing screenshot '#{full_path}'")
              editor.frame!
            end
          rescue => ex
            UI.error(ex.to_s)
            UI.error("Backtrace:\n\t#{ex.backtrace.join("\n\t")}") if FastlaneCore::Globals.verbose?
          end
        end
      else
        UI.error("Could not find screenshots in current directory: '#{File.expand_path(path)}'")
      end
    end
  end
end
