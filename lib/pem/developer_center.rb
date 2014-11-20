require 'deliver/password_manager'
require 'open-uri'
require 'openssl'

require 'capybara'
require 'capybara/poltergeist'

module PEM
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
    APP_IDS_URL = "https://developer.apple.com/account/ios/identifiers/bundle/bundleList.action"

    # Strings
    PRODUCTION_SSL_CERTIFICATE_TITLE = "Production SSL Certificate"

    def initialize
      FileUtils.mkdir_p TMP_FOLDER

      DependencyChecker.check_dependencies
      
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

      self.login
    end

    # Loggs in a user with the given login data on the Dev Center Frontend.
    # You don't need to pass a username and password. It will
    # Automatically be fetched using the {Deliver::PasswordManager}.
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

        user ||= Deliver::PasswordManager.shared_manager.username
        password ||= Deliver::PasswordManager.shared_manager.password

        result = visit DEVELOPER_CENTER_URL
        raise "Could not open Developer Center" unless result['status'] == 'success'

        wait_for_elements(".button.blue").first.click

        (wait_for_elements('#accountpassword') rescue nil) # when the user is already logged in, this will raise an exception

        if page.has_content?"My Apps"
          # Already logged in
          return true
        end

        fill_in "accountname", with: user
        fill_in "accountpassword", with: password

        begin
          all(".button.large.blue.signin-button").first.click

          wait_for_elements('#aprerelease')
        rescue Exception => ex
          Helper.log.debug ex
          raise DeveloperCenterLoginError.new("Error logging in user #{user} with the given password. Make sure you entered them correctly.")
        end

        Helper.log.info "Login successful"

        true
      rescue Exception => ex
        error_occured(ex)
      end
    end

    def app_status(app_identifier)
      # TODO
    end

    # This method will enable push for the given app
    # and download the cer file in any case, no matter if it existed before or not
    # @return the path to the push file
    def fetch_cer_file(app_identifier)
      begin
        open_app_page(app_identifier)

        click_on "Edit"
        wait_for_elements(".item-details") # just to finish loading

        push_value = first(:css, '#pushEnabled').value
        if push_value == "on"
          Helper.log.info "Push for app '#{app_identifier}' is enabled"
        else
          Helper.log.warn "Push for app '#{app_identifier}' is disabled. This has to change."
          first(:css, '#pushEnabled').click
        end

        sleep 1

        # Example code
        # <div class="appCertificates">
        #   <h3>Apple Push Notification service SSL Certificates</h3>
        #   <p>To configure push notifications for this iOS App ID, a Client SSL Certificate that allows your notification server to connect to the Apple Push Notification Service is required. Each iOS App ID requires its own Client SSL Certificate. Manage and generate your certificates below.</p>
        #   <div class="title" data-hires-status="replaced">Development SSL Certificate</div>
        #   <div class="createCertificate">
        #     <p>Create  certificate to use for this App ID.</p>
        #       <a class="button small navLink development enabled" href="/account/ios/certificate/certificateRequest.action?appIdId=...&amp;types=..."><span>Create Certificate...</span></a>
        #   </div>              
        #   <div class="title" data-hires-status="replaced">Production SSL Certificate</div>
        #   <div class="certificate">
        #     <dl>
        #       <dt>Name:</dt>
        #       <dd>Apple Production iOS Push Services: net.sunapps.151</dd>
        #       <dt>Type:</dt>
        #       <dd>APNs Production iOS</dd>
        #       <dt>Expires:</dt>
        #       <dd>Nov 14, 2015</dd>
        #     </dl>
        #     <a class="button small revoke-button" href="https://developer.apple.com/services-account/QH65B2/account/ios/certificate/revokeCertificate.action?content-type=application/x-www-form-urlencoded&amp;accept=application/json&amp;requestId=....;userLocale=en_US&amp;teamId=...&amp;certificateId=...&amp;type=...."><span>Revoke</span></a>
        #     <a class="button small download-button" href="/account/ios/certificate/certificateContentDownload.action?displayId=....&amp;type=..."><span>Download</span></a>                  
        #   </div>
        #   <div class="createCertificate">
        #     <p>Create an additional certificate to use for this App ID.</p>
        #       <a class="button small navLink distribution enabled" href="/account/ios/certificate/certificateRequest.action?appIdId=...&amp;types=..."><span>Create Certificate...</span></a>              
        #   </div>
        # </div>

        def find_download_button
          wait_for_elements(".formContent")

          certificates_block = first('.appCertificates')
          download_button = nil

          production_section = false
          certificates_block.all(:xpath, "./div").each do |div|
            if production_section
              # We're now in the second part, we only care about production certificates
              if (download_button = div.first(".download-button"))
                return download_button
              end
            end

            production_section = true if div.text == PRODUCTION_SSL_CERTIFICATE_TITLE
          end
          nil
        end


        download_button = find_download_button

        if not download_button
          Helper.log.warn "Push for app '#{app_identifier}' is enabled, but there is no production certificate yet."
          create_push_for_app(app_identifier)

          download_button = find_download_button
          raise "Could not find download button for Production SSL Certificate. Check out: '#{current_url}'" unless download_button
        end


        Helper.log.info "Going to download the latest profile"

        # It is enabled, now just download it
        # Taken from http://stackoverflow.com/a/17111206/445598
        sleep 2

        host = Capybara.current_session.current_host
        url = download_button['href']
        url = [host, url].join('')
        
        myacinfo = page.driver.cookies['myacinfo'].value # some magic Apple, which is required for the profile download
        data = open(url, {'Cookie' => "myacinfo=#{myacinfo}"}).read

        raise "Something went wrong when downloading the certificate" unless data

        path = "#{TMP_FOLDER}/aps_production_#{app_identifier}.cer"
        File.write(path, data)

        Helper.log.info "Successfully downloaded latest .cer file."
        return path

      rescue Exception => ex
        error_occured(ex)
      end
    end


    private
      def open_app_page(app_identifier)
        begin
          visit APP_IDS_URL

          apps = all(:xpath, "//td[@title='#{app_identifier}']")
          if apps.count == 1
            apps.first.click
            sleep 1

            return true
          else
            raise DeveloperCenterGeneralError.new("Could not find app with identifier '#{app_identifier}' on apps page.")
          end
        rescue Exception => ex
          error_occured(ex)
        end
      end

      def create_push_for_app(app_identifier)
        wait_for_elements('.button.small.navLink.distribution.enabled').last.click # Create Certificate button

        sleep 2

        click_next # "Continue"

        sleep 1
        wait_for_elements(".button.small.center.back") # just to wait

        # Upload CSR file
        first(:xpath, "//input[@type='file']").set PEM::SigningRequest.get_path

        click_next # "Generate"

        while all(:css, '.loadingMessage').count > 0
          Helper.log.debug "Waiting for iTC to generate the profile"
          sleep 2
        end

        open_app_page(app_identifier)
        click_on "Edit"
      end


    private
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
            Helper.log.debug page.html
            Helper.log.debug caller
            raise DeveloperCenterGeneralError.new("Couldn't find element '#{name}' after waiting for quite some time")
          end
        end
        return results
      end
  end
end