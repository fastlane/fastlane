require 'fastlane_core/developer_center/developer_center'

module PEM
  class DeveloperCenter < FastlaneCore::DeveloperCenter
    APP_IDS_URL = "https://developer.apple.com/account/ios/identifiers/bundle/bundleList.action"

    
    # This method will enable push for the given app
    # and download the cer file in any case, no matter if it existed before or not
    # @return the path to the push file
    def fetch_cer_file
      @app_identifier = PEM.config[:app_identifier]
      begin
        open_app_page

        click_on "Edit"
        wait_for_elements(".item-details") # just to finish loading

        push_value = first(:css, '#pushEnabled').value
        if push_value == "on"
          Helper.log.info "Push for app '#{@app_identifier}' is enabled"
        else
          Helper.log.warn "Push for app '#{@app_identifier}' is disabled. This has to change."
          first(:css, '#pushEnabled').click
          sleep 3 # this takes some time
        end

        Helper.log.warn "Creating push certificate for app '#{@app_identifier}'."
        create_push_for_app
      rescue => ex
        error_occured(ex)
      end
    end


    private
      def open_app_page
        begin
          visit APP_IDS_URL
          sleep 5

          wait_for_elements(".toolbar-button.search").first.click
          fill_in "bundle-list-search", with: @app_identifier
          sleep 5

          apps = all(:xpath, "//td[@title='#{@app_identifier}']")
          if apps.count == 1
            apps.first.click
            sleep 2

            return true
          else
            raise DeveloperCenterGeneralError.new("Could not find app with identifier '#{@app_identifier}' on apps page. The identifier is case sensitive.")
          end
        rescue => ex
          error_occured(ex)
        end
      end

      def create_push_for_app

        element_name = (PEM.config[:development] ? '.button.small.navLink.development.enabled' : '.button.small.navLink.distribution.enabled')
        begin
          wait_for_elements(element_name).first.click # Create Certificate button
        rescue
          raise "Could not create a new push profile for app '#{@app_identifier}'. There are already 2 certificates active. Please revoke one to let PEM create a new one\n\n#{current_url}".red
        end

        sleep 2

        click_next # "Continue"

        sleep 1

        wait_for_elements(".file-input.validate")
        wait_for_elements(".button.small.center.back")

        # Upload CSR file
        first(:xpath, "//input[@type='file']").set PEM::SigningRequest.get_path

        click_next # "Generate"

        while all(:css, '.loadingMessage').count > 0
          Helper.log.debug "Waiting for iTC to generate the profile"
          sleep 2
        end

        certificate_type = (PEM.config[:development] ? 'development' : 'production')

        # Download the newly created certificate
        Helper.log.info "Going to download the latest profile"

        # It is enabled, now just download it
        sleep 2

        download_button = first(".button.small.blue")
        host = Capybara.current_session.current_host
        url = download_button['href']
        url = [host, url].join('')
        Helper.log.info "Downloading URL: '#{url}'"
        
        cookieString = ""
        
        page.driver.cookies.each do |key, cookie|
          cookieString << "#{cookie.name}=#{cookie.value};" # append all known cookies
        end  
        
        data = open(url, {'Cookie' => cookieString}).read

        raise "Something went wrong when downloading the certificate" unless data

        path = "#{TMP_FOLDER}aps_#{certificate_type}_#{@app_identifier}.cer"
        dataWritten = File.write(path, data)
        
        if dataWritten == 0
          raise "Can't write to #{TMP_FOLDER}"
        end
        
        Helper.log.info "Successfully downloaded latest .cer file to '#{path}'".green
        return path
      end

      def click_next
        wait_for_elements('.button.small.blue.right.submit').last.click
      end
  end
end
