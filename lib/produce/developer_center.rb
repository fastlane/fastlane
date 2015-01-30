require 'credentials_manager/password_manager'
require 'open-uri'
require 'openssl'

require 'capybara'
require 'capybara/poltergeist'

module Produce
  class DeveloperCenter
    # This error occurs only if there is something wrong with the given login data
    class DeveloperCenterLoginError < StandardError 
    end

    # This error can occur for many reaons. It is
    # usually raised when a UI element could not be found
    class DeveloperCenterGeneralError < StandardError
    end

    # Types of certificates
    APPSTORE = "AppStore"
    ADHOC = "AdHoc"
    DEVELOPMENT = "Development"

    include Capybara::DSL

    DEVELOPER_CENTER_URL = "https://developer.apple.com/devcenter/ios/index.action"
    APPS_URL = "https://developer.apple.com/account/ios/identifiers/bundle/bundleList.action"
    CREATE_APP_URL = "https://developer.apple.com/account/ios/identifiers/bundle/bundleCreate.action"



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

        result = visit APPS_URL
        raise "Could not open Developer Center" unless result['status'] == 'success'

        if page.has_content?"Member Center"
          # Already logged in
          return true
        end

        (wait_for_elements(".button.blue").first.click rescue nil) # maybe already logged in

        (wait_for_elements('#accountpassword') rescue nil) # when the user is already logged in, this will raise an exception

        if page.has_content?"Member Center"
          # Already logged in
          return true
        end

        fill_in "accountname", with: user
        fill_in "accountpassword", with: password

        all(".button.large.blue.signin-button").first.click

        begin
          if page.has_content?"Select Team" # If the user is not on multiple teams
            select_team
          end
        rescue => ex
          Helper.log.debug ex
          raise DeveloperCenterLoginError.new("Error loggin in user #{user}. User is on multiple teams and we were unable to correctly retrieve them.")
        end

        begin
          wait_for_elements('.toolbar-button.add.navLink')
          visit APPS_URL # again, since after the login, the dev center loses the GET value
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
      team_id = ENV["PRODUCE_TEAM_ID"]
      team_id = nil if team_id.to_s.length == 0

      team_name = ENV["PRODUCE_TEAM_NAME"]
      team_name = nil if team_name.to_s.length == 0

      if team_id == nil and team_name == nil
        Helper.log.info "You can store you preferred team using the environment variable `PRODUCE_TEAM_ID` or `PRODUCE_TEAM_NAME`".green
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

      result = visit APPS_URL
      raise "Could not open Developer Center" unless result['status'] == 'success'
    end

    def run
      create_new_app
    rescue => ex
      error_occured(ex)
    end

    def create_new_app
      if app_exists?
        Helper.log.info "App '#{Config.val(:app_name)}' already exists, nothing to do on the Dev Center".green
        ENV["CREATED_NEW_APP_ID"] = nil
        # Nothing to do here
      else
        Helper.log.info "Creating new app '#{Config.val(:app_name)}' on the Apple Dev Center".green
        visit CREATE_APP_URL
        wait_for_elements("*[name='appIdName']").first.set Config.val(:app_name)
        wait_for_elements("*[name='explicitIdentifier']").first.set Config.val(:bundle_identifier)
        click_next

        sleep 3 # sometimes this takes a while and we don't want to timeout

        wait_for_elements("form[name='bundleSubmit']") # this will show the summary of the given information
        click_next

        sleep 3 # sometimes this takes a while and we don't want to timeout

        wait_for_elements(".ios.bundles.confirmForm.complete")
        click_on "Done"

        raise "Something went wrong when creating the new app - it's not listed in the App's list" unless app_exists?

        ENV["CREATED_NEW_APP_ID"] = Time.now.to_s

        Helper.log.info "Finished creating new app '#{Config.val(:app_name)}' on the Dev Center".green
      end

      return true
    end


    private
      def app_exists?
        visit APPS_URL

        wait_for_elements("td[aria-describedby='grid-table_identifier']").each do |app|
          identifier = app['title']

          return true if identifier.to_s == Config.val(:bundle_identifier).to_s
        end

        false
      end

      def click_next
        wait_for_elements('.button.small.blue.right.submit').last.click
      end

      def error_occured(ex)
        snap
        raise ex # re-raise the error after saving the snapshot
      end

      def snap
        path = "Error#{Time.now.to_i}.png"
        save_screenshot(path, :full => true)
        system("open '#{path}'")
      end

      def wait_for(method, parameter, success)
        counter = 0
        result = method.call(parameter)
        while !success.call(result)     
          sleep 0.2

          result = method.call(parameter)

          counter += 1
          if counter > 100
            Helper.log.debug caller
            raise DeveloperCenterGeneralError.new("Couldn't find '#{parameter}' after waiting for quite some time")
          end
        end
        return result
      end

      def wait_for_elements(name)
        method = Proc.new { |n| all(name) }
        success = Proc.new { |r| r.count > 0 }
        return wait_for(method, name, success)
      end

      def wait_for_variable(name)
        method = Proc.new { |n|
          retval = page.html.match(/var #{n} = "(.*)"/)
          retval[1] unless retval == nil
        }
        success = Proc.new { |r| r != nil }
        return wait_for(method, name, success)
      end
  end
end
