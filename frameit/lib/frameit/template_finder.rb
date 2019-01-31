require 'deliver/app_screenshot'

require_relative 'module'
require_relative 'device_types'
require_relative 'frame_downloader'

module Frameit
  # Responsible for finding the correct device
  class TemplateFinder
    # This will detect the screen size and choose the correct template
    def self.get_template(screenshot, color)
      return nil if screenshot.mac?

      # fallbacks for Frameit::Color::BLACK for devices that call that color something else
      if color == Frameit::Color::BLACK && !Frameit.config[:use_legacy_iphone6s]
        # iPhone 6/7 Plus                                                            #  iPhone 6/7
        if screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_55 || screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_47
          color = "Matte Black" # RIP space gray
        # iPhone XR
        elsif screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_61
          color = "Black"
        end
      end

      filename = "Apple #{screenshot.device_name} #{color}"
      templates = Dir["#{FrameDownloader.templates_path}/#{filename}.{png,jpg}"] # ~/.frameit folder

      UI.verbose("Looking for #{filename} and found #{templates.count} template(s)")

      if templates.count == 0
        # Known cases why a template could be missing (and fallbacks)
        if screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_35
          UI.important("Unfortunately 3.5\" device frames were discontinued. Skipping screen '#{screenshot.path}'")
          UI.error("Looked for: '#{filename}.png'")
        elsif color == Frameit::Color::ROSE_GOLD || color == Frameit::Color::GOLD
          # Not every device type is available in rose gold or gold.
          # Fallback to a white iPhone, which looks similar-ish.
          UI.important("Unfortunately device type '#{screenshot.device_name}' is not available in #{color}, falling back to white/silver...")
          color = Frameit::Color::SILVER
          return self.get_template(screenshot, color)
        else
          UI.error("Couldn't find template for screenshot type '#{filename}'")
          UI.error("Please run `fastlane frameit download_frames` to download the latest frames")
        end
        return filename if Helper.test?
        return nil
      else
        return templates.first.tr(" ", "\ ")
      end
    end
  end
end
