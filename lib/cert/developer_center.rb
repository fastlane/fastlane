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

    # This will check if there is at least one of the certificates already installed on the local machine
    def run
      file = find_existing_cert
      if file
        # We don't need to do anything :)
        ENV["CER_FILE_PATH"] = file
      else
        create_certificate
      end
    rescue => ex
      error_occured(ex)
    end

    def find_existing_cert
      visit "#{CERTS_URL}?type=distribution"

      # Download all available certs to check if they are installed using the SHA1 hash
      certs = code_signing_certificate
      certs.each do |current|
        display_id = current['certificateId']
        type_id = current['certificateTypeDisplayId']
        url = "/account/ios/certificate/certificateContentDownload.action?displayId=#{display_id}&type=#{type_id}"

        output = File.join(TMP_FOLDER, "#{display_id}-#{type_id}.cer")
        download_url(url, output)
        if Cert::CertChecker.is_installed?output
          # We'll use this one, since it's installed on the local machine
          Helper.log.info "Found the certificate #{display_id}-#{type_id} which is installed on the local machine. Using this one.".green
          return output
        end
      end

      Helper.log.info "Couldn't find an existing certificate... creating a new one"
      return false
    rescue => ex
      error_occured(ex)
    end

    # This will actually create a new certificate
    def create_certificate
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
      sleep 2
      click_next # information about how to upload the file (no action required on this step)

      cert_signing_request = Cert::SigningRequest.get_path
      Helper.log.info "Uploading the cert signing request '#{cert_signing_request}'"
      

      wait_for_elements("input[name='upload']").first.set cert_signing_request # upload the cert signing request
      sleep 1
      click_next

      sleep 3

      while all(:css, '.loadingMessage').count > 0
        Helper.log.debug "Waiting for iTC to generate the profile"
        sleep 2
      end

      Helper.log.info "Downloading newly generated certificate"
      sleep 2

      # Now download the certificate
      download_button = wait_for_elements(".button.small.blue").first
      url = download_button['href']
      
      download_url(url, File.join(TMP_FOLDER, "certificate.cer"))
      
      ENV["CER_FILE_PATH"] = path
      Helper.log.info "Successfully downloaded latest .cer file to '#{path}'".green
    rescue => ex
      error_occured(ex)
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

      def download_url(url, output_path)
        host = Capybara.current_session.current_host
        url = [host, url].join('')
        Helper.log.info "Downloading URL: '#{url}'"

        cookieString = ""
        page.driver.cookies.each do |key, cookie|
          cookieString << "#{cookie.name}=#{cookie.value};" # append all known cookies
        end  
        data = open(url, {'Cookie' => cookieString}).read

        raise "Something went wrong when downloading the certificate" unless data

        dataWritten = File.write(output_path, data)
        
        if dataWritten == 0
          raise "Can't write to #{output_path}"
        end
      end

      # Returns a hash, that contains information about the iOS certificate
      # @example
        # {"certRequestId"=>"B23Q2P396B",
        # "name"=>"SunApps GmbH",
        # "statusString"=>"Issued",
        # "expirationDate"=>"2015-11-25T22:45:50Z",
        # "expirationDateString"=>"Nov 25, 2015",
        # "ownerType"=>"team",
        # "ownerName"=>"SunApps GmbH",
        # "ownerId"=>"....",
        # "canDownload"=>true,
        # "canRevoke"=>true,
        # "certificateId"=>"....",
        # "certificateStatusCode"=>0,
        # "certRequestStatusCode"=>4,
        # "certificateTypeDisplayId"=>"...",
        # "serialNum"=>"....",
        # "typeString"=>"iOS Distribution"},
      def code_signing_certificate
        certs_url = "https://developer.apple.com/account/ios/certificate/certificateList.action?type=distribution"
        visit certs_url

        certificateDataURL = wait_for_variable('certificateDataURL')
        certificateRequestTypes = wait_for_variable('certificateRequestTypes')
        certificateStatuses = wait_for_variable('certificateStatuses')

        url = [certificateDataURL, certificateRequestTypes, certificateStatuses].join('')

        # https://developer.apple.com/services-account/.../account/ios/certificate/listCertRequests.action?content-type=application/x-www-form-urlencoded&accept=application/json&requestId=...&userLocale=en_US&teamId=...&types=...&status=4&certificateStatus=0&type=distribution

        available = []

        certs = post_ajax(url)['certRequests']
        certs.each do |current_cert|
          if current_cert['typeString'] == 'iOS Distribution' 
            # The other profiles are push profiles
            # We only care about the distribution profile
            available << current_cert # mostly we only care about the 'certificateId'
          end
        end

        return available        
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

      def post_ajax(url)
        JSON.parse(page.evaluate_script("$.ajax({type: 'POST', url: '#{url}', async: false})")['responseText'])
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
