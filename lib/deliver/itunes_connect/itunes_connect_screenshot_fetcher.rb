require 'open-uri'

module Deliver
  # For all the information reading (e.g. version number)
  class ItunesConnect < FastlaneCore::ItunesConnect
    # This method will download all existing app screenshots
    # @param app (Deliver::App) the app you want this information from
    # @param folder_path (String) the path to store the screenshots in
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def download_existing_screenshots(app, folder_path)
      languages = JSON.parse(File.read(File.join(Helper.gem_path('deliver'), "lib", "assets", "DeliverLanguageMapping.json")))

      begin
        verify_app(app)

        url = ALL_INFORMATION_URL + app.apple_id.to_s

        # Turn off/on the async mode of jQuery
        evaluate_script("jQuery.ajaxSetup({async:false});")
        response = evaluate_script("$.get('#{url}').responseText")
        evaluate_script("jQuery.ajaxSetup({async:true});")

        raise "Could not fetch previously uploaded screenshots" unless response

        data = JSON.parse(response)
        screenshots = data['data']['details']['value'].each do |language_values|
          language_code = languages.find { |a| a['name'] == language_values['language'] }
          unless language_code
            Helper.log.error "Could not find language information for language #{language_values['language']}".red
            next
          end
          language_code = language_code['locale']

          language_values['screenshots']['value'].each do |type, value|
            value['value'].each do |screenshot|
              url = screenshot['value']['url']
              file_name = [screenshot['value']['sortOrder'], type, screenshot['value']['originalFileName']].join("_")
              Helper.log.info "Downloading existing screenshot '#{file_name}' of device type: '#{type}'"

              containing_folder = File.join(folder_path, "screenshots", language_code)
              FileUtils.mkdir_p containing_folder rescue nil # if it's already there
              path = File.join(containing_folder, file_name)
              File.write(path, open(url).read)
            end
          end
        end
      rescue Exception => ex
        error_occured(ex)
      end
    end
  end
end