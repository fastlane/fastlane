module FastlaneCore
  class DeveloperCenter
    # Log in a user with the given login data on the Dev Center Frontend.
    # You don't need to pass a username and password. It will
    # Automatically be fetched using the {CredentialsManager::PasswordManager}.
    # This method will also automatically be called when triggering other 
    # actions like {#open_app_page}
    # @param user (String) (optional) The username/email address
    # @param password (String) (optional) The password
    # @return (bool) true if everything worked fine
    # @raise [DeveloperCenterGeneralError] General error while executing 
    #  this action
    # @raise [DeveloperCenterLoginError] Login data is wrong
    def login(user = nil, password = nil)
      begin
        Helper.log.info "Login into iOS Developer Center"

        user ||= CredentialsManager::PasswordManager.shared_manager.username
        password ||= CredentialsManager::PasswordManager.shared_manager.password

        result = visit PROFILES_URL
        raise "Could not open Developer Center" unless result['status'] == 'success'

        # Already logged in
        select_team if current_url.include?"selectTeam.action"
        return true if (page.has_content? "Member Center" and not current_url.include?"selectTeam.action")

        (wait_for_elements(".button.blue").first.click rescue nil) # maybe already logged in

        (wait_for_elements('#accountpassword') rescue nil) # when the user is already logged in, this will raise an exception

        # Already logged in
        select_team if current_url.include?"selectTeam.action"
        return true if (page.has_content? "Member Center" and not current_url.include?"selectTeam.action")

        fill_in "accountname", with: user
        fill_in "accountpassword", with: password

        all(".button.large.blue.signin-button").first.click

        begin
          # If the user is not on multiple teams
          select_team if current_url.include?"selectTeam.action"
        rescue => ex
          Helper.log.debug ex
          raise DeveloperCenterLoginError.new("Error loggin in user #{user}. User is on multiple teams and we were unable to correctly retrieve them.")
        end

        begin
          wait_for_elements('.ios.profiles.gridList')
          visit PROFILES_URL # again, since after the login, the dev center loses the production GET value
        rescue => ex
          if page.has_content?"Getting Started"
            visit PROFILES_URL # again, since after the login, the dev center loses the production GET value
          else
            Helper.log.debug ex
            raise DeveloperCenterLoginError.new("Error logging in user #{user} with the given password. Make sure you entered them correctly.".red)
          end
        end

        Helper.log.info "Login successful"
        
        true
      rescue => ex
        error_occured(ex)
      end
    end


    def select_team
      team_id = ENV["FASTLANE_TEAM_ID"] || CredentialsManager::AppfileConfig.try_fetch_value(:team_id)

      team_name = ENV["FASTLANE_TEAM_NAME"] || CredentialsManager::AppfileConfig.try_fetch_value(:team_name)

      if team_id == nil and team_name == nil
        Helper.log.info "You can store your preferred team using the environment variable `FASTLANE_TEAM_ID` or `FASTLANE_TEAM_NAME`".green
        Helper.log.info "or in your `Appfile` using `team_id 'Q2CBPJ58CA'` or `team_name 'Felix Krause'`".green
        Helper.log.info "Your ID belongs to the following teams:".green
      end
      
      available_options = []

      teams = find("div.input").all('.team-value') # Grab all the teams data
      teams.each_with_index do |val, index|
        current_team_id = '"' + val.find("input").value + '"'
        team_text = val.find(".label-primary").text
        description_text = val.find(".label-secondary").text
        description_text = "(#{description_text})" unless description_text.empty? # Include the team description if any
        index_text = (index + 1).to_s + "."

        available_options << [index_text, current_team_id, team_text, description_text].join(" ")
      end

      if team_name
        # Search for name
        found_it = false
        all("label.label-primary").each do |current|
          if current.text.downcase.gsub(/\s+/, "") == team_name.downcase.gsub(/\s+/, "")
            current.click # select the team by name
            found_it = true
          end
        end

        unless found_it
          available_teams = all("label.label-primary").collect { |a| a.text }
          raise DeveloperCenterLoginError.new("Could not find Team with name '#{team_name}'. Available Teams: #{available_teams}".red)
        end
      else
        # Search by ID/Index
        unless team_id
          puts available_options.join("\n").green
          team_index = ask("Please select the team number you would like to access: ".green)
          team_id = teams[team_index.to_i - 1].find(".radio").value
        end

        team_button = first(:xpath, "//input[@type='radio' and @value='#{team_id}']") # Select the desired team
        if team_button
          team_button.click
        else
          Helper.log.fatal "Could not find given Team. Available options: ".red
          puts available_options.join("\n").yellow
          raise DeveloperCenterLoginError.new("Error finding given team #{team_id}.".red)
        end
      end

      all(".button.large.blue.submit").first.click

      result = visit PROFILES_URL
      raise "Could not open Developer Center" unless result['status'] == 'success'
    end
  end
end
