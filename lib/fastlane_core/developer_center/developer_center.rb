require 'credentials_manager/password_manager'
require 'open-uri'

require 'capybara'
require 'capybara/poltergeist'
require 'phantomjs/poltergeist'

require 'fastlane_core/developer_center/developer_center_login'
require 'fastlane_core/developer_center/developer_center_helper'
require 'fastlane_core/developer_center/developer_center_signing_certificates'

module FastlaneCore
  class DeveloperCenter
    # This error occurs only if there is something wrong with the given login data
    class DeveloperCenterLoginError < StandardError 
    end

    # This error can occur for many reaons. It is
    # usually raised when a UI element could not be found
    class DeveloperCenterGeneralError < StandardError
    end

    include Capybara::DSL

    DEVELOPER_CENTER_URL = "https://developer.apple.com/devcenter/ios/index.action"
    TMP_FOLDER = "/tmp/fastlane_core/"

    def initialize
      FileUtils.mkdir_p TMP_FOLDER
      
      Capybara.run_server = false
      Capybara.default_driver = :poltergeist
      Capybara.javascript_driver = :poltergeist
      Capybara.current_driver = :poltergeist
      Capybara.app_host = DEVELOPER_CENTER_URL

      # Since Apple has some SSL errors, we have to configure the client properly:
      # https://github.com/ariya/phantomjs/issues/11239
      Capybara.register_driver :poltergeist do |a|
        conf = ['--debug=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1']
        Capybara::Poltergeist::Driver.new(a, {
          phantomjs: Phantomjs.path,
          phantomjs_options: conf,
          phantomjs_logger: File.open("#{TMP_FOLDER}/poltergeist_log.txt", "a"),
          js_errors: false
        })
      end

      page.driver.headers = { "Accept-Language" => "en" }

      self.login
    end

    # Loggs in a user with the given login data on the Dev Center Frontend.
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
        return true if page.has_content? "Member Center"

        (wait_for_elements(".button.blue").first.click rescue nil) # maybe already logged in

        (wait_for_elements('#accountpassword') rescue nil) # when the user is already logged in, this will raise an exception

        # Already logged in
        return true if page.has_content? "Member Center"

        fill_in "accountname", with: user
        fill_in "accountpassword", with: password

        all(".button.large.blue.signin-button").first.click

        begin
          # If the user is not on multiple teams
          select_team if page.has_content? "Select Team"
        rescue => ex
          Helper.log.debug ex
          raise DeveloperCenterLoginError.new("Error loggin in user #{user}. User is on multiple teams and we were unable to correctly retrieve them.")
        end

        begin
          wait_for_elements('.ios.profiles.gridList')
          visit PROFILES_URL # again, since after the login, the dev center loses the production GET value
        rescue => ex
          Helper.log.debug ex
          if page.has_content?"Getting Started"
            raise "There was no valid signing certificate found. Please log in and follow the 'Getting Started guide' on '#{current_url}'".red
          else
            raise DeveloperCenterLoginError.new("Error logging in user #{user} with the given password. Make sure you entered them correctly.")
          end
        end

        Helper.log.info "Login successful"
        
        true
      rescue => ex
        error_occured(ex)
      end
    end


    def select_team
      team_id = ENV["FASTLANE_TEAM_ID"]
      team_id = nil if team_id.to_s.length == 0

      unless team_id
        Helper.log.info "You can store you preferred team using the environment variable `FASTLANE_TEAM_ID`".green
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

      all(".button.large.blue.submit").first.click

      result = visit PROFILES_URL
      raise "Could not open Developer Center" unless result['status'] == 'success'
    end
  end
end
