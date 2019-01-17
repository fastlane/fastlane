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

      # color config (unless specified via CLI)
      unless color
        color = Frameit::Color::BLACK
        color = Frameit::Color::SILVER if Frameit.config[:white] || Frameit.config[:silver]
        color = Frameit::Color::GOLD if Frameit.config[:gold]
        color = Frameit::Color::ROSE_GOLD if Frameit.config[:rose_gold]
      end

      screenshots = Dir.glob("#{path}/**/*.{png,PNG}").uniq # uniq because thanks to {png,PNG} there are duplicates

      if screenshots.count > 0
        screenshots.each do |full_path|
          # skip screenshots we are not interested in
          next if full_path.include?("_framed.png")
          next if full_path.include?(".itmsp/") # a package file, we don't want to modify that
          next if full_path.include?("device_frames/") # these are the device frames the user is using
          # skip all Apple Watch screenshots: we don't care about watches right now
          if apple_watch_screenshot?(full_path)
            UI.error("Apple Watch screenshots are not framed: '#{full_path}'")
            next
          end

          #new
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
            #/new
           #old 
          Helper.show_loading_indicator("Framing screenshot '#{full_path}'")

          config = fetch_config(full_path)
          
          begin
            screenshot = Screenshot.new(full_path, color)
            screenshot.frame!(config)
            screenshot.wrap!(config)
          #old
          rescue => ex
            UI.error(ex.to_s)
            UI.error("Backtrace:\n\t#{ex.backtrace.join("\n\t")}") if FastlaneCore::Globals.verbose?
          ensure
            Helper.error_loading_indicator # If the spinner is still running, make sure it indicates and error
          end
        end
      else
        UI.error("Could not find screenshots in current directory: '#{File.expand_path(path)}'")
      end
    end

    def apple_watch_screenshot?(full_path)
      device = full_path.rpartition('/').last.partition('-').first # extract device name
      device.downcase.include?("watch")
    end 

    # Loads the config (colors, background, texts, etc.)
    # Don't use this method to access the actual text and use `fetch_texts` instead
    def fetch_config(path)
      return @config[path] if @config && @config[path]

      config_path = File.join(File.expand_path("..", path), "Framefile.json")
      config_path = File.join(File.expand_path("../..", path), "Framefile.json") unless File.exist?(config_path)
      file = ConfigParser.new.load(config_path)
      return {} unless file # no config file at all
      @config[path] = file.fetch_value(path)
    end
  end
end
