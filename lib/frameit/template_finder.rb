module Frameit
  # Responsible for finding the correct device
  class TemplateFinder

    # This will detect the screen size and choose the correct template
    def self.get_template(screenshot)
      return nil if screenshot.is_mac?
      parts = [
        screenshot.device_name,
        screenshot.orientation_name,
        screenshot.color
      ]
      parts << "sRGB" if screenshot.device_name == 'iPad_mini'


      templates_path = [ENV['HOME'], FrameConverter::FRAME_PATH].join('/')
      templates = Dir["../**/#{parts.join('_')}*.{png,jpg}"] # local directory
      templates = templates + Dir["#{templates_path}/**/#{parts.join('_')}*.{png,jpg}"] # ~/.frameit folder
      

      if templates.count == 0
        if screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_35
          Helper.log.warn "Unfortunately 3.5\" device frames were discontinued. Skipping screen '#{screenshot.path}'".yellow
          Helper.log.debug "Looked for: '#{parts.join('_')}.png'".red
        else
          Helper.log.error "Could not find a valid template for screenshot '#{screenshot.path}'".red
          Helper.log.error "You can download new templates from '#{FrameConverter::DOWNLOAD_URL}'"
          Helper.log.error "and store them in '#{templates_path}'"
          Helper.log.error "Missing file: '#{parts.join('_')}.png'".red
        end
        return nil
      else
        return templates.first.gsub(" ", "\ ")
      end
    end
  end
end