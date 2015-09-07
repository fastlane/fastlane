module Snapshot
  # This class takes care of removing the alpha channel of the generated screenshots
  class ScreenshotFlatten
    # @param (String) The path in which the screenshots are located in
    def run(path)
      Helper.log.info "Removing the alpha channel from generated png files"
      flatten(path)
    end

    def flatten(path)
      Dir.glob([path, '/**/*.png'].join('/')).each do |file|
        Helper.log.info "Removing alpha channel from '#{file}'" if $verbose
        `sips -s format bmp '#{file}' &> /dev/null ` # &> /dev/null because there is warning because of the extension
        `sips -s format png '#{file}'`
      end
    end
  end
end