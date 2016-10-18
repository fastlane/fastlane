module Frameit
  # Responsible for finding the correct device
  class TemplateFinder
    # This will detect the screen size and choose the correct template
    def self.get_template(screenshot)
      return nil if screenshot.mac?

      filename = "Apple #{screenshot.device_name} #{screenshot.color}"

      templates = Dir["#{FrameDownloader.templates_path}/#{filename}.{png,jpg}"] # ~/.frameit folder

      UI.verbose "Looking for #{filename} and found #{templates.count} template(s)"

      if templates.count == 0
        if screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_35
          UI.important "Unfortunately 3.5\" device frames were discontinued. Skipping screen '#{screenshot.path}'"
          UI.error "Looked for: '#{filename}.png'"
        else
          # TODO: implement this here
          require 'pry'
          binding.pry
          UI.error("Couldn't find template")
        end
        return nil
      else
        return templates.first.tr(" ", "\ ")
      end
    end
  end
end
