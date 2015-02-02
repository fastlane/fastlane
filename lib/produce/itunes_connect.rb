require 'capybara'
require 'capybara/poltergeist'
require 'credentials_manager/password_manager'

module Produce
  # Every method you call here, might take a time
  class ItunesConnect
    # This error occurs only if there is something wrong with the given login data
    class ItunesConnectLoginError < StandardError 
    end

    # This error can occur for many reaons. It is
    # usually raised when a UI element could not be found
    class ItunesConnectGeneralError < StandardError
    end

    include Capybara::DSL

    ITUNESCONNECT_URL = "https://itunesconnect.apple.com/"
    APPS_URL = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app"

    NEW_APP_CLASS = ".new-button.ng-isolate-scope"
    
    def initialize(config)
      @config = config

      DependencyChecker.check_dependencies
      
      Capybara.run_server = false
      Capybara.default_driver = :poltergeist
      Capybara.javascript_driver = :poltergeist
      Capybara.current_driver = :poltergeist
      Capybara.app_host = ITUNESCONNECT_URL

      # Since Apple has some SSL errors, we have to configure the client properly:
      # https://github.com/ariya/phantomjs/issues/11239
      Capybara.register_driver :poltergeist do |a|
        conf = ['--debug=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1']
        Capybara::Poltergeist::Driver.new(a, {
          phantomjs_options: conf,
          phantomjs_logger: File.open("/tmp/poltergeist_log.txt", "a"),
          js_errors: false
        })
      end

      page.driver.headers = { "Accept-Language" => "en" }

      self.login
    end

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
      begin
        Helper.log.info "Logging into iTunesConnect"

        user ||= CredentialsManager::PasswordManager.shared_manager.username
        password ||= CredentialsManager::PasswordManager.shared_manager.password

        result = visit ITUNESCONNECT_URL
        raise "Could not open iTunesConnect" unless result['status'] == 'success'

        (wait_for_elements('#accountpassword') rescue nil) # when the user is already logged in, this will raise an exception

        if page.has_content?"My Apps"
          # Already logged in
          return true
        end

        fill_in "accountname", with: user
        fill_in "accountpassword", with: password

        begin
          (wait_for_elements(".enabled").first.click rescue nil) # Login Button
          wait_for_elements('.homepageWrapper.ng-scope')
          
          if page.has_content?"My Apps"
            # Everything looks good
          else
            raise ItunesConnectLoginError.new("Looks like your login data was correct, but you do not have access to the apps.")
          end
        rescue => ex
          Helper.log.debug(ex)
          raise ItunesConnectLoginError.new("Error logging in user #{user} with the given password. Make sure you entered them correctly.")
        end

        Helper.log.info "Successfully logged into iTunesConnect"

        true
      rescue => ex
        error_occured(ex)
      end
    end

    def run
      if ENV["CREATED_NEW_APP_ID"].to_i > 0
        # We just created this App ID, this takes about 3 minutes to show up on iTunes Connect
        Helper.log.info "Waiting for 3 minutes to make sure, the App ID is synced to iTunes Connect".yellow
        sleep 180
        unless app_exists?
          Helper.log.info "Couldn't find new app yet, we're waiting for another 2 minutes.".yellow
          sleep 120
        end
      end

      return create_new_app
    rescue => ex
      error_occured(ex)
    end

    def create_new_app
      if app_exists?
        Helper.log.info "App '#{config[:app_name]}' exists already, nothing to do on iTunes Connect".green
        # Nothing to do here
      else
        Helper.log.info "Creating new app '#{config[:app_name]}' on iTunes Connect".green

        initial_create

        initial_pricing

        raise "Something went wrong when creating the new app - it's not listed in the App's list" unless app_exists?

        Helper.log.info "Finished creating new app '#{config[:app_name]}' on iTunes Connect".green
      end

      return fetch_apple_id
    end

    def fetch_apple_id
      # First try it using the Apple API
      data = JSON.parse(open("https://itunes.apple.com/lookup?bundleId=#{config[:bundle_identifier]}").read)

      if data['resultCount'] == 0 or true
        visit current_url
        sleep 10
        first("input[ng-model='searchModel']").set config[:bundle_identifier]

        if all("div[bo-bind='app.name']").count == 2
          raise "There were multiple results when looking for the new app. This might be due to having same app identifiers included in each other (see generated screenshots)".red
        end

        app_url = first("a[bo-href='appBundleLink(app.adamId, app.type)']")[:href]
        apple_id = app_url.split('/').last

        Helper.log.info "Found Apple ID #{apple_id}".green
        return apple_id
      else
        return data['results'].first['trackId'] # already in the store
      end
    end

    def initial_create
      open_new_app_popup
      
      # Fill out the initial information
      wait_for_elements("input[ng-model='createAppDetails.newApp.name.value']").first.set config[:app_name]
      wait_for_elements("input[ng-model='createAppDetails.versionString.value']").first.set config[:version]
      wait_for_elements("input[ng-model='createAppDetails.newApp.vendorId.value']").first.set config[:sku]
      
      wait_for_elements("option[value='#{config[:bundle_identifier]}']").first.select_option
      all(:xpath, "//option[text()='#{config[:primary_language]}']").first.select_option

      click_on "Create"
      sleep 5 # this usually takes some time

      if all("p[ng-repeat='error in errorText']").count == 1
        raise all("p[ng-repeat='error in errorText']").first.text.to_s.red # an error when creating this app
      end

      wait_for_elements(".language.hasPopOver") # looking good

      Helper.log.info "Successfully created new app '#{config[:app_name]}' on iTC. Setting up the initial information now.".green
    end

    def initial_pricing
      sleep 3
      click_on "Pricing"
      first('#pricingPopup > option[value="3"]').select_option
      first('.saveChangesActionButton').click
    end

    private
      def app_exists?
        open_new_app_popup # to get the dropdown of available app identifier, if it's there, the app was not yet created

        sleep 4

        return (all("option[value='#{config[:bundle_identifier]}']").count == 0)
      end

      def open_new_app_popup
        visit APPS_URL
        sleep 5 # this usually takes some time 

        wait_for_elements(NEW_APP_CLASS).first.click
        wait_for_elements('#new-menu > * > a').first.click # Create a new App

        sleep 5 # this usually takes some time - this is important
        wait_for_elements("input[ng-model='createAppDetails.newApp.name.value']") # finish loading
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
            raise ItunesConnectGeneralError.new("Couldn't find element '#{name}' after waiting for quite some time")
          end
        end
        return results
      end
  end
end
