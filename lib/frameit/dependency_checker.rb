module Frameit
  class DependencyChecker
    def self.check_dependencies
      self.check_image_magick
      # self.check_xctool
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

    # def self.check_xctool
    #   if not self.xctool_installed?
    #     Helper.log.error '#############################################################'
    #     Helper.log.error "# xctool is recommended to build the apps"
    #     Helper.log.error "# Install it using 'brew install xctool'"
    #     Helper.log.error "# Falling back to xcode build instead "
    #     Helper.log.error '#############################################################'
    #   end
    # end
  end
end