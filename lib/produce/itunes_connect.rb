require 'capybara'
require 'capybara/poltergeist'
require 'fastimage'
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
    
    def initialize
      super

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
      create_new_app
    rescue => ex
      error_occured(ex)
    end

    def create_new_app
      if app_exists?
        Helper.log.info "App '#{Config.val(:app_name)}' exists already, nothing to do on iTunes Connect".green
        # Nothing to do here
      else
        Helper.log.info "Creating new app '#{Config.val(:app_name)}' on iTunes Connect".green

        initial_create

        set_pricing

        raise "Something went wrong when creating the new app - it's not listed in the App's list" unless app_exists?

        Helper.log.info "Finished creating new app '#{Config.val(:app_name)}' on iTunes Connect".green
      end

      return true
    end

    def initial_create
      open_new_app_popup
      
      # Fill out the initial information
      wait_for_elements("input[ng-model='createAppDetails.newApp.name.value']").first.set Config.val(:app_name)
      wait_for_elements("input[ng-model='createAppDetails.versionString.value']").first.set Config.val(:version)
      wait_for_elements("input[ng-model='createAppDetails.newApp.vendorId.value']").first.set Config.val(:sku)
      
      wait_for_elements("option[value='#{Config.val(:bundle_identifier)}']").first.select_option
      all(:xpath, "//option[text()='#{Config.val(:primary_language)}']").first.select_option

      click_on "Create"
      sleep 5 # this usually takes some time

      if all("p[ng-repeat='error in errorText']").count == 1
        raise all("p[ng-repeat='error in errorText']").first.text.to_s.red # an error when creating this app
      end

      wait_for_elements(".language.hasPopOver") # looking good

      Helper.log.info "Successfully created new app '#{Config.val(:app_name)}' on iTC. Setting up the initial information now.".green
    end

    def set_pricing
      tier = Config.val(:pricing_tier)
      raise "Invalid tier '#{tier}' given, must be 0 to 94".red unless (tier.to_i >= 0 and tier.to_i <= 94)

      click_on "Pricing"
      wait_for_elements("#pricingPopup > option[value='#{tier}']").first.select_option
      wait_for_elements(".saveChangesActionButton").last.click # Save

      raise "Something went wrong when storing the pricing information".red unless wait_for_elements(".completed-icon").count == 1
      Helper.log.info "Successfully set the pricing to #{tier} Tier".green

      wait_for_elements(".cancelActionButton").last.click
      sleep 5 # this usually takes some time
    end

    private
      def app_exists?
        open_new_app_popup # to get the dropdown of available app identifier, if it's there, the app was not yet created

        return all("option[value='#{Config.val(:bundle_identifier)}']").count == 0
      end

      def open_new_app_popup
        visit APPS_URL

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
            Helper.log.debug page.html
            Helper.log.debug caller
            raise ItunesConnectGeneralError.new("Couldn't find element '#{name}' after waiting for quite some time")
          end
        end
        return results
      end
  end
end
