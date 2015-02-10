require 'credentials_manager/password_manager'
require 'open-uri'
require 'openssl'

require 'capybara'
require 'capybara/poltergeist'
require 'phantomjs/poltergeist'

module Cert
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
    CERTS_URL = "https://developer.apple.com/account/ios/certificate/certificateList.action"
    CREATE_CERT_URL = "https://developer.apple.com/account/ios/certificate/certificateCreate.action"

    # Strings
    PRODUCTION_SSL_CERTIFICATE_TITLE = "Production SSL Certificate"
    DEVELOPMENT_SSL_CERTIFICATE_TITLE = "Development SSL Certificate"

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

        result = visit CERTS_URL
        raise "Could not open Developer Center" unless result['status'] == 'success'

        wait_for_elements(".button.blue").first.click

        (wait_for_elements('#accountpassword') rescue nil) # when the user is already logged in, this will raise an exception

        if page.has_content?"My Apps"
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
          visit CERTS_URL
          wait_for_elements('.toolbar-heading-all')

          sleep 3
        rescue => ex
          Helper.log.debug ex
          raise DeveloperCenterLoginError.new("Error logging in user #{user} with the given password. Make sure you entered them correctly.")
        end

        Helper.log.info "Login successful"

        true
      rescue => ex
        error_occured(ex)
      end
    end

    def create_cert
      visit CREATE_CERT_URL
      wait_for_elements("form[name='certificateSave']")

      Helper.log.info "Creating a new code signing certificate"

      # select certificate type
      app_store_toggle = first("input#type-iosNoOCSP")
      if !!app_store_toggle['disabled']
        # Limit of certificates already reached
        raise "Could not create another certificate, reached the maximum number of available certificates.".red
      end

      app_store_toggle.click

      click_next # submit the certificate type
      click_next # information about how to upload the file (no action required on this step)

      Helper.log.info "Uploading the cert signing request"
      cert_signing_request = Cert::SigningRequest.get_path

      wait_for_elements("input[name='upload']").first.set cert_signing_request # upload the cert signing request
      click_next

      while all(:css, '.loadingMessage').count > 0
        Helper.log.debug "Waiting for iTC to generate the profile"
        sleep 2
      end

      Helper.log.info "Downloading newly generated certificate"
      sleep 2


      # Now download the certificate
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

      path = File.join(TMP_FOLDER, "certificate.cer")
      dataWritten = File.write(path, data)
      
      if dataWritten == 0
        raise "Can't write to #{TMP_FOLDER}"
      end
      
      Helper.log.info "Successfully downloaded latest .cer file to '#{path}'".green
    end



    private
      def select_team
        team_id = ENV["CERT_TEAM_ID"]
        team_id = nil if team_id.to_s.length == 0

        unless team_id
          Helper.log.info "You can store you preferred team using the environment variable `CERT_TEAM_ID`".green
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

        result = visit CERTS_URL
        raise "Could not open Developer Center" unless result['status'] == 'success'
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
            raise DeveloperCenterGeneralError.new("Couldn't find element '#{name}' after waiting for quite some time")
          end
        end
        return results
      end
  end
end
