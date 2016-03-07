module Frameit
  # Responsible for finding the correct device
  class TemplateFinder
    # This will detect the screen size and choose the correct template
    def self.get_template(screenshot)
      return nil if screenshot.mac?
      parts = [
        screenshot.device_name,
        screenshot.orientation_name,
        screenshot.color
      ]
      joiner = "_"

      if screenshot.device_name.include?('iPad') || screenshot.device_name.include?('6s')
        parts = [
          screenshot.device_name,
          (screenshot.color == 'SpaceGray' ? "Space-Gray" : "Silver"),
          (screenshot.orientation_name == "Horz" ? "horizontal" : "vertical")
        ]
        joiner = "-"
      end

      templates_path = [ENV['HOME'], FrameConverter::FRAME_PATH].join('/')
      templates = Dir["../**/#{parts.join(joiner)}*.{png,jpg}"] # local directory
      templates += Dir["#{templates_path}/**/#{parts.join(joiner)}*.{png,jpg}"] # ~/.frameit folder

      if templates.count == 0
        if screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_35
          UI.important "Unfortunately 3.5\" device frames were discontinued. Skipping screen '#{screenshot.path}'"
          UI.error "Looked for: '#{parts.join(joiner)}.png'"
        else
          UI.error "Could not find a valid template for screenshot '#{screenshot.path}'"
          UI.error "You can download new templates from '#{FrameConverter::DOWNLOAD_URL}'"
          UI.error "and store them in '#{templates_path}'"
          UI.error "Missing file: '#{parts.join(joiner)}.png'"
        end
        return nil
      else
        return templates.first.tr(" ", "\ ")
      end
    end
  end
end
