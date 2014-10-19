require 'ios_deploy_kit/password_manager'

require 'capybara'
require 'capybara/poltergeist'
require 'security'


module IosDeployKit
  # Everything that can't be achived using the {IosDeployKit::ItunesTransporter}
  # will be scripted using the iTunesConnect frontend.
  # 
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
    APP_DETAILS_URL = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/[[app_id]]"

    BUTTON_STRING_NEW_VERSION = "New Version"
    BUTTON_STRING_SUBMIT_FOR_REVIEW = "Submit for Review"
    
    def initialize
      super
      
      Capybara.run_server = false
      Capybara.default_driver = :poltergeist
      Capybara.javascript_driver = :poltergeist
      Capybara.current_driver = :poltergeist
      Capybara.app_host = ITUNESCONNECT_URL

      # Since Apple has some SSL errors, we have to configure the client properly:
      # https://github.com/ariya/phantomjs/issues/11239
      Capybara.register_driver :poltergeist do |a|
        conf = ['--debug=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1']
        Capybara::Poltergeist::Driver.new(a, phantomjs_options: conf)
      end

      self.login
    end

    # Loggs in a user with the given login data on the iTC Frontend.
    # You don't need to pass a username and password. It will
    # Automatically be fetched using the {IosDeployKit::PasswordManager}.
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
        return true if @logged_in

        Helper.log.info "Logging into iTunesConnect"

        user ||= PasswordManager.new.username
        password ||= PasswordManager.new.password

        result = visit ITUNESCONNECT_URL
        raise "Could not open iTunesConnect" unless result['status'] == 'success'

        fill_in "accountname", with: user
        fill_in "accountpassword", with: password

        begin
          wait_for_elements(".enabled").first.click
          wait_for_elements('.ng-scope.managedWidth')
        rescue
          ItunesConnectLoginError.new("Error logging in user #{user} with the given password. Make sure you set them correctly")
        end

        Helper.log.info "Successfully logged into iTunesConnect"
        @logged_in = true
        true
      rescue Exception => ex
        error_occured(ex)
      end
    end

    # Opens the app details page of the given app.
    # @param app (IosDeployKit::App) the app that should be opened
    # @return (bool) true if everything worked fine
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def open_app_page(app)
      verify_app(app)

      self.login

      Helper.log.info "Opening detail page for app #{app}"

      visit APP_DETAILS_URL.gsub("[[app_id]]", app.apple_id.to_s)

      wait_for_elements('.page-subnav')

      true
    end

    # This method will fetch the current status ({IosDeployKit::App::AppStatus}) 
    # of your app and return it. This method uses a headless browser
    # under the hood, so it might take some time until you get the result
    # @param app (IosDeployKit::App) the app you want this information from
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def get_app_status(app)
      verify_app(app)

      self.login

      open_app_page(app)

      if page.has_content?"Waiting For Review"
        # That's either Upload Received or Waiting for Review
        if page.has_content?"To submit a new build, you must remove this version from review"
          return App::AppStatus::WAITING_FOR_REVIEW
        else
          return App::AppStatus::UPLOAD_RECEIVED
        end
      elsif page.has_content?BUTTON_STRING_NEW_VERSION
        return App::AppStatus::READY_FOR_SALE
      elsif page.has_content?BUTTON_STRING_SUBMIT_FOR_REVIEW
        return App::AppStatus::PREPARE_FOR_SUBMISSION
      else
        raise "App status not yet implemented"
      end
    end



    # Constructive/Destructive Methods

    # This method creates a new version of your app using the
    # iTunesConnect frontend. This will happen directly after calling
    # this method. 
    # @param app (IosDeployKit::App) the app you want to modify
    # @param version_number (String) the version number as string for 
    # the new version that should be created
    def create_new_version!(app, version_number)
      verify_app(app)

      self.login

      open_app_page(app)

      if page.has_content?BUTTON_STRING_NEW_VERSION
        click_on BUTTON_STRING_NEW_VERSION

        Helper.log.info "Creating a new version (#{version_number})"
        
        all(".fullWidth.nobottom.ng-isolate-scope.ng-pristine").last.set(version_number.to_s)
        click_on "Create"
      else
        Helper.log.info "Creating a new version"
      end

      true
    end



    private
      def verify_app(app)
        raise ItunesConnectGeneralError.new("No valid IosDeployKit::App given") unless app.kind_of?IosDeployKit::App
        raise ItunesConnectGeneralError.new("App is missing information") unless (app.apple_id || '').to_s.length > 5
      end

      def error_occured(ex)
        path = "Error#{Time.now.to_i}.png"
        save_screenshot(path, :full => true)
        system("open '#{path}'")
        raise ex # re-raise the error after saving the snapshot
      end

      def wait_for_elements(name)
        counter = 0
        results = all(name)
        while results.count == 0      
          Helper.log.debug "Waiting for #{name}"
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