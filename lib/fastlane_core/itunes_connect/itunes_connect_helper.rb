module FastlaneCore  
  class ItunesConnect
    # All the private helpers
    private
      # Opens the app details page of the given app.
      # @param app (Deliver::App) the app that should be opened
      # @return (bool) true if everything worked fine
      # @raise [ItunesConnectGeneralError] General error while executing 
      #  this action
      # @raise [ItunesConnectLoginError] Login data is wrong
      def open_app_page(app)
        verify_app(app)

        Helper.log.info "Opening detail page for app #{app}"

        visit APP_DETAILS_URL.gsub("[[app_id]]", app.apple_id.to_s)

        wait_for_elements('.page-subnav')
        sleep 5

        if current_url.include?"wa/defaultError" # app could not be found
          raise "Could not open app details for app '#{app}'. Make sure you're using the correct Apple ID and the correct Apple developer account (#{CredentialsManager::PasswordManager.shared_manager.username}).".red
        end

        true
      rescue => ex
        error_occured(ex)
      end

      
      def verify_app(app)
        raise ItunesConnectGeneralError.new("No valid Deliver::App given") unless app.kind_of?Deliver::App
        raise ItunesConnectGeneralError.new("App is missing information (apple_id not given)") unless (app.apple_id || '').to_s.length > 5
      end

      def error_occured(ex)
        snap
        raise ex # re-raise the error after saving the snapshot
      end

      def snap
        path = File.expand_path("Error#{Time.now.to_i}.png")
        save_screenshot(path, :full => true)
        system("open '#{path}'") unless ENV['SIGH_DISABLE_OPEN_ERROR']
      end

      # Since Apple takes for ages, after the upload is properly processed, we have to wait here
      def wait_for_preprocessing
        started = Time.now

        # Wait, while iTunesConnect is processing the uploaded file
        while (page.has_content?"Uploaded")
          # iTunesConnect is super slow... so we have to wait...
          Helper.log.info("Sorry, we have to wait for iTunesConnect, since it's still processing the uploaded ipa file\n" + 
            "If this takes longer than 45 minutes, you have to re-upload the ipa file again.\n" + 
            "You can always open the browser page yourself: '#{current_url}'\n" +
            "Passed time: ~#{((Time.now - started) / 60.0).to_i} minute(s)")
          sleep 30
          visit current_url
          sleep 30
        end
      end

      def wait_for_elements(name)
        counter = 0
        results = all(name)
        while results.count == 0      
          # Helper.log.debug "Waiting for #{name}"
          sleep 0.2

          results = all(name)

          counter += 1
          if counter > 100
            Helper.log.debug caller
            raise ItunesConnectGeneralError.new("Couldn't find element '#{name}' after waiting for quite some time")
          end
        end
        return results
      end
  end
end