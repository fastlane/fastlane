module Frameit
  class DependencyChecker
    def self.check_dependencies
      return if Helper.is_test?
      
      self.check_image_magick
    end

    def self.check_image_magick
      unless `which convert`.include?"convert"
        Helper.log.fatal '#############################################################'
        Helper.log.fatal "# You have to install the ImageMagick to use FrameIt"
        Helper.log.fatal "# Install it using 'brew update && brew install imagemagick'"
        Helper.log.fatal "# If you don't have homebrew: http://brew.sh"
        Helper.log.fatal '#############################################################'
        raise "Install ImageMagick and start frameit again!"
      end
    end
  end
end