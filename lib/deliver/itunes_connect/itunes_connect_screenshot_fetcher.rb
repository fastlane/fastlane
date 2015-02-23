require 'open-uri'

module FastlaneCore  
  # For all the information reading (e.g. version number)
  class ItunesConnect
    ALL_INFORMATION_URL = "https://itunesconnect.apple.com//WebObjects/iTunesConnect.woa/ra/apps/version/"

    # This method will download all existing app screenshots
    # @param app (Deliver::App) the app you want this information from
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def download_existing_screenshots(app)
      begin
        verify_app(app)

        url = ALL_INFORMATION_URL + app.apple_id.to_s

        # Turn off/on the async mode of jQuery
        evaluate_script("jQuery.ajaxSetup({async:false});")
        response = evaluate_script("$.get('#{url}').responseText")
        evaluate_script("jQuery.ajaxSetup({async:true});")

        raise "Could not fetch previously uploaded screenshots" unless response

        data = JSON.parse(response)

        # TODO: instead of .first, it should iterate through all langauges!
        screenshots = data['data']['details']['value'].first['screenshots']['value']

        screenshots.each do |type, value|
          value['value'].each do |screenshot|
            url = screenshot['value']['url']
            file_name = [screenshot['value']['sortOrder'], type, screenshot['value']['originalFileName']].join("_")
            Helper.log.info "Downloading screenshot '#{file_name}' of device type: '#{type}'"
            language = "en-US" # TODO 

            containing_folder = File.join(".", "screenshots", language)
            FileUtils.mkdir_p containing_folder
            path = File.join(containing_folder, file_name)
            File.write(path, open(url).read)
          end
        end
      rescue Exception => ex
        error_occured(ex)
      end
    end
  end
end