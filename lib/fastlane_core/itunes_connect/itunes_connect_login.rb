module FastlaneCore  
  # Login code
  class ItunesConnect
    # Loggs in a user with the given login data on the iTC Frontend.
    # You don't need to pass a username and password. It will
    # Automatically be fetched using the {CredentialsManager::PasswordManager}.
    # This method will also automatically be called when triggering other 
    # actions like {#open_app_page}
    # @param user (String) (optional) The username/email address
    # @param password (String) (optional) The password
    # @return (bool) true if everything worked fine
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def login(user = nil, password = nil)
      Helper.log.info "Logging into iTunesConnect"

      user ||= CredentialsManager::PasswordManager.shared_manager.username
      password ||= CredentialsManager::PasswordManager.shared_manager.password

      result = visit ITUNESCONNECT_URL
      raise "Could not open iTunesConnect" unless result['status'] == 'success'

      sleep 3
      
      if page.has_content?"My Apps"
        # Already logged in
        return true
      end

      begin
        wait_for_elements('#accountpassword')
      rescue => ex
        # when the user is already logged in, this will raise an exception
      end

      fill_in "accountname", with: user
      fill_in "accountpassword", with: password

      begin
        (wait_for_elements(".enabled").first.click rescue nil) # Login Button
        wait_for_elements('.ng-scope')
        
        if page.has_content?"My Apps"
          # Everything looks good
        else
          visit current_url # iTC sometimes is super buggy, try reloading the site
          sleep 3
          unless page.has_content?"My Apps"
            raise ItunesConnectLoginError.new("Looks like your login data was correct, but you do not have access to the apps.".red)
          end
        end
      rescue => ex
        Helper.log.debug(ex)
        raise ItunesConnectLoginError.new("Error logging in user #{user} with the given password. Make sure you entered them correctly.".red)
      end

      Helper.log.info "Successfully logged into iTunesConnect"

      true
    rescue => ex
      error_occured(ex)
    end
  end
end