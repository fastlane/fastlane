require_relative 'frame_downloader'
require_relative 'module'
require_relative 'device_types' # color + orientation
require_relative 'screenshot'
require_relative 'frame'
require_relative 'framer'
require_relative 'wrapper/wrapper'
require_relative 'wrapper/mac_wrapper'

module Frameit
  class Runner
    def initialize
      downloader = FrameDownloader.new
      unless downloader.frames_exist?
        downloader.download_frames
      end
    end

    def run(path, cli_color = nil)

      screenshots = Dir.glob("#{path}/**/*.{png,PNG}").uniq # uniq because thanks to {png,PNG} there are duplicates

      if screenshots.count > 0
        screenshots.each do |full_path|

          # skip screenshots we are not interested in
          next if full_path.include?("_framed.png")
          next if full_path.include?("_wrapped.png")
          next if full_path.include?(".itmsp/") # a package file, we don't want to modify that
          next if full_path.include?("device_frames/") # these are the device frames the user is using
          # skip all Apple Watch screenshots: we don't care about watches right now
          if apple_watch_screenshot?(full_path)
            UI.error("Apple Watch screenshots are not framed: '#{full_path}'")
            next
          end

          # Get the config from Framefile.json etc
          framefile_config = fetch_framefile_config_for_screenshot(full_path)
          
          begin
            # Start with plain screenshot
            screenshot = Screenshot.new(full_path)

            # Get the correct frame for this screenshot (in the specified or configured color)
            frame = Frame.new(screenshot, cli_color, framefile_config)

            if should_skip?(framefile_config)
              UI.message("Skipping framing of screenshot #{screenshot.path}. No title provided in your Framefile.json or title.strings.")
            else
              Helper.show_loading_indicator("Framing screenshot '#{full_path}'")

              # Add the frame
              framed_screenshot = Framer.new.frame!(screenshot, frame, framefile_config) if frame
              framed_screenshot = screenshot unless frame # Mac screenshots don't get a frame

              # And optionally wrap it
              if is_complex_framing?(framefile_config)
                if self.mac?
                  wrapped_screenshot = MacWrapper.new.frame!(framed_screenshot, framefile_config, screenshot.size)
                else
                  wrapped_screenshot = Wrapper.new.wrap!(framed_screenshot, framefile_config, screenshot.size)
                end
              end
            end
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

    def should_skip?(framefile_config)
      return is_complex_framing?(framefile_config) && !framefile_config['title']
    end

    # Do we add a background and title as well?
    def is_complex_framing?(framefile_config)
      return (framefile_config['background'] and (framefile_config['title'] or framefile_config['keyword']))
    end

    # Loads the config (colors, background, texts, etc.)
    # Don't use this method to access the actual text and use `fetch_texts` instead
    def fetch_framefile_config_for_screenshot(screenshot_path)
      return @framefile_config_cache[screenshot_path] if @framefile_config_cache && @framefile_config_cache[screenshot_path]

      config_path = File.join(File.expand_path("..", screenshot_path), "Framefile.json")
      config_path = File.join(File.expand_path("../..", screenshot_path), "Framefile.json") unless File.exist?(config_path)
      file = ConfigParser.new.load(config_path)
      
      return {} unless file # no config file at all

      @framefile_config_cache = {} if !@framefile_config_cache # initialize empty hash if doesn't exist yet
      @framefile_config_cache[screenshot_path] = file.fetch_value(screenshot_path)
    end
  end
end
