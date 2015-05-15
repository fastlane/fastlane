require 'open-uri'

module Deliver
  # For all the information reading (e.g. version number)
  class ItunesConnect < FastlaneCore::ItunesConnect
    ALL_INFORMATION_URL = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/version/"

    # This method will download information for a given app
    # @param app (Deliver::App) the app you want this information from
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def get_app_information(app)
      begin
        verify_app(app)

        url = ALL_INFORMATION_URL + app.apple_id.to_s

        # Turn off/on the async mode of jQuery
        evaluate_script("jQuery.ajaxSetup({async:false});")
        response = evaluate_script("$.get('#{url}').responseText")
        evaluate_script("jQuery.ajaxSetup({async:true});")

        raise "Could not fetch data for app" unless response

        data = JSON.parse(response)

        return data['data']
      rescue Exception => ex
        error_occured(ex)
      end
    end
  end
end