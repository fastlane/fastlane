require 'deliver/app_screenshot'

require_relative 'module'
require_relative 'device_types'
require_relative 'frame_downloader'

module Frameit
  # Responsible for finding the correct device
  class TemplateFinder
    # This will detect the screen size and choose the correct template
    def self.get_template(screenshot)
      return nil if screenshot.mac?

      filename = "Apple #{screenshot.device_name} #{screenshot.color}"

      templates = Dir["#{FrameDownloader.templates_path}/#{filename}.{png,jpg}"] # ~/.frameit folder

      UI.verbose("Looking for #{filename} and found #{templates.count} template(s)")

      if templates.count == 0
        if screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_35
          UI.important("Unfortunately 3.5\" device frames were discontinued. Skipping screen '#{screenshot.path}'")
          UI.error("Looked for: '#{filename}.png'")
        elsif screenshot.color == Frameit::Color::ROSE_GOLD || screenshot.color == Frameit::Color::GOLD
          # Unfortunately not every device type is available in rose gold or gold
          # This is why we can't have nice things #yatusabes
          # fallback to a white iPhone, which looks similar
          UI.important("Unfortunately device type '#{screenshot.device_name}' is not available in #{screenshot.color}, falling back to silver...")
          screenshot.color = Frameit::Color::SILVER
          return self.get_template(screenshot)
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
