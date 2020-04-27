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

    def run(path, color = nil, platform = nil)
      unless color
        color = Frameit::Color::SILVER if Frameit.config[:white] || Frameit.config[:silver]
        color = Frameit::Color::GOLD if Frameit.config[:gold]
        color = Frameit::Color::ROSE_GOLD if Frameit.config[:rose_gold]
      end

      screenshots = Dir.glob("#{path}/**/*.{png,PNG}").uniq # uniq because thanks to {png,PNG} there are duplicates

      if screenshots.count > 0
        screenshots.each do |full_path|
          next if skip_path?(full_path)

          begin
            config = create_config(full_path)
            screenshot = Screenshot.new(full_path, color, config, platform)

            next if skip_up_to_date?(screenshot)

            editor = editor(screenshot, config)

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

    def skip_path?(path)
      return true if path.include?("_framed.png")
      return true if path.include?(".itmsp/") # a package file, we don't want to modify that
      return true if path.include?("device_frames/") # these are the device frames the user is using
      device = path.rpartition('/').last.partition('-').first # extract device name
      if device.downcase.include?("watch")
        UI.error("Apple Watch screenshots are not framed: '#{path}'")
        return true # we don't care about watches right now
      end
      false
    end

    def skip_up_to_date?(screenshot)
      if !screenshot.outdated? && Frameit.config[:resume]
        UI.message("Skipping framing of screenshot #{screenshot.path} because its framed file seems up-to-date.")
        return true
      end
      false
    end

    def editor(screenshot, config)
      if screenshot.mac?
        return MacEditor.new(screenshot, config)
      else
        return Editor.new(screenshot, config, Frameit.config[:debug_mode])
      end
    end

    # Loads the config (colors, background, texts, etc.)
    # Don't use this method to access the actual text and use `fetch_texts` instead
    def create_config(screenshot_path)
      # Screengrab pulls screenshots to a different folder location
      # frameit only handles two levels of folders, to not break
      # compatibility with Supply we look into a different path for Android
      # Issue https://github.com/fastlane/fastlane/issues/16289
      config_path = File.join(File.expand_path("..", screenshot_path), "Framefile.json")
      config_path = File.join(File.expand_path("../..", screenshot_path), "Framefile.json") unless File.exist?(config_path)
      config_path = File.join(File.expand_path("../../../..", screenshot_path), "Framefile.json") unless File.exist?(config_path)
      file = ConfigParser.new.load(config_path)
      return {} unless file # no config file at all
      file.fetch_value(screenshot_path)
    end
  end
end
