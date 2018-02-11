require_relative 'module'

module Frameit
  class DependencyChecker
    def self.check_dependencies
      return if Helper.test?

      self.check_image_magick
    end

    def self.check_image_magick
      unless `which convert`.include?("convert")
        UI.error('#############################################################')
        UI.error("# You have to install the ImageMagick to use FrameIt")
        UI.error("# Install it using 'brew update && brew install imagemagick'")
        UI.error("# If you don't have homebrew: http://brew.sh")
        UI.error('#############################################################')
        UI.user_error!("Install ImageMagick and start frameit again!")
      end
    end
  end
end
