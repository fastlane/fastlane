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

      filename = create_file_name(screenshot.device_name, screenshot.color.nil? ? screenshot.default_color : screenshot.color)
      templates = Dir["#{FrameDownloader.templates_path}/#{filename}.{png,jpg}"] # ~/.frameit folder

      UI.verbose("Looking for #{filename} and found #{templates.count} template(s)")

      return filename if Helper.test?
      if templates.count == 0 && !screenshot.color.nil? && screenshot.color != screenshot.default_color
        filename = create_file_name(screenshot.device_name, screenshot.default_color)
        UI.important("Unfortunately device type '#{screenshot.device_name}' is not available in #{screenshot.color}, falling back to " + (screenshot.default_color.nil? ? "default" : screenshot.default_color) + "...")
        templates = Dir["#{FrameDownloader.templates_path}/#{filename}.{png,jpg}"] # ~/.frameit folder
        UI.verbose("Looking for #{filename} and found #{templates.count} template(s)")
      end

      if templates.count == 0
        if screenshot.deliver_screen_id == Deliver::AppScreenshot::ScreenSize::IOS_35
          UI.important("Unfortunately 3.5\" device frames were discontinued. Skipping screen '#{screenshot.path}'")
          UI.error("Looked for: '#{filename}.png'")
        else
          UI.error("Couldn't find template for screenshot type '#{filename}'")
          UI.error("Please run `fastlane frameit download_frames` to download the latest frames")
        end
        return nil
      else
        return templates.first.tr(" ", "\ ")
      end
    end

    def self.create_file_name(device_name, color)
      return "#{device_name} #{color}" unless color.nil?
      return device_name
    end
  end
end
