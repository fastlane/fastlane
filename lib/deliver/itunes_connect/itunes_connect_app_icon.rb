require 'fastimage'

module Deliver
  class ItunesConnect < FastlaneCore::ItunesConnect
    # Uploading a new full size app icon

    def upload_app_icon!(app, path)
      path = File.expand_path(path)
      raise "Could not find app icon at path '#{path}'".red unless File.exists?path

      size = FastImage.size(path)
      raise "App icon must have the resolution of 1024x1024px".red unless (size[0] == 1024 and size[1] == 1024)

      # Remove alpha channel
      Helper.log.info "Removing alpha channel from provided App Icon (iTunes Connect requirement)".green
      
      `sips -s format bmp '#{path}' &> /dev/null ` # &> /dev/null since there is warning because of the extension
      `sips -s format png '#{path}'`

      begin
        verify_app(app)
        open_app_page(app)

        Helper.log.info "Starting upload of new app icon".green

        evaluate_script("$('.appversionicon:not(.watchIcon) > .ios7-style-icon').prev().click()") # delete button
        evaluate_script("$('[style-class=\"appversionicon rounded\"] [itc-launch-filechooser] + input').attr('id', 'deliverFileUploadInput')") # set div
        evaluate_script("URL = webkitURL; URL.createObjectURL = function(){return 'blob:abc'}"); # shim URL
        page.attach_file("deliverFileUploadInput", path) # add file

        sleep 10

        click_on "Save"

        Helper.log.info "Finished uploading the new app icon".green
      rescue => ex
        error_occured(ex)
      end
    end
  end
end