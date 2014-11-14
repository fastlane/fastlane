module Snapshot
  # This class takes care of removing the alpha channel of the generated screenshots
  class ScreenshotFlatten
    # @param (String) The path in which the screenshots are located in
    def run(path)
      if image_magick_installed?
        flatten(path)
      else
        Helper.log.info "Could not remove transparency of generated screenhots.".yellow
        Helper.log.info "This will cause problems when trying to manually upload them to iTC.".yellow
        Helper.log.info "You can install 'imagemagick' using 'brew install imagemagick' to enable this feature.".yellow
      end
    end

    def flatten(path)
      Dir.glob([path, '**/*.png'].join('/')).each do |file|
        `convert -flatten '#{file}' -alpha off -alpha remove '#{file}'`
      end
    end

    def image_magick_installed?
      `which convert`.length > 1
    end
  end
end