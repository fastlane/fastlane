require 'deliver/password_manager'

require 'capybara'
require 'capybara/poltergeist'
require 'security'


module Deliver
  # Everything that can't be achived using the {Deliver::ItunesTransporter}
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

    BUTTON_ADD_NEW_BUILD = 'Click + to add a build before you submit your app.'
    
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
    # Automatically be fetched using the {Deliver::PasswordManager}.
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

        true
      rescue Exception => ex
        error_occured(ex)
      end
    end

    # Opens the app details page of the given app.
    # @param app (Deliver::App) the app that should be opened
    # @return (bool) true if everything worked fine
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def open_app_page(app)
      begin
        verify_app(app)

        Helper.log.info "Opening detail page for app #{app}"

        visit APP_DETAILS_URL.gsub("[[app_id]]", app.apple_id.to_s)

        wait_for_elements('.page-subnav')

        true
      rescue Exception => ex
        error_occured(ex)
      end
    end

    # This method will fetch the current status ({Deliver::App::AppStatus})
    # of your app and return it. This method uses a headless browser
    # under the hood, so it might take some time until you get the result
    # @param app (Deliver::App) the app you want this information from
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def get_app_status(app)
      begin
        verify_app(app)

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
      rescue Exception => ex
        error_occured(ex)
      end
    end



    # Constructive/Destructive Methods

    # This method creates a new version of your app using the
    # iTunesConnect frontend. This will happen directly after calling
    # this method. 
    # @param app (Deliver::App) the app you want to modify
    # @param version_number (String) the version number as string for 
    # the new version that should be created
    def create_new_version!(app, version_number)
      begin
        verify_app(app)
        open_app_page(app)

        if page.has_content?BUTTON_STRING_NEW_VERSION
          click_on BUTTON_STRING_NEW_VERSION

          Helper.log.info "Creating a new version (#{version_number})"
          
          all(".fullWidth.nobottom.ng-isolate-scope.ng-pristine").last.set(version_number.to_s)
          click_on "Create"
        else
          Helper.log.info "Version #{version_number} was already created"
        end

        true
      rescue Exception => ex
        error_occured(ex)
      end
    end

    # This will choose the latest uploaded build on iTunesConnect as the production one
    # After this method, you still have to call submit_for_review to actually submit the
    # whole update
    # @param app (Deliver::App) the app you want to choose the build for
    def put_build_into_production!(app)
      begin
        verify_app(app)
        open_app_page(app)

        Helper.log("Choosing the latest build on iTunesConnect.")

        while not page.has_content?"Add Build"
          click_on BUTTON_ADD_NEW_BUILD
          sleep 1
        end

        
        # TODO: Sorted correctly?
        result = page.first('td', :text => '0.9.11').first(:xpath,"./..").first(:css, ".small").click
        click_on "Done" # Save the modal dialog
        click_on "Save" # on the top right to save everything else

        error = page.has_content?BUTTON_ADD_NEW_BUILD
        raise "Could not put build itself onto production. Try opening '#{current_url}'" if error

        return true
      rescue
        error_occured(ex)
      end
    end

    # Submits the update itself to Apple, this includes the app metadata and the ipa file
    # This can easily cause exceptions, which will be shown on iTC.
    # @param app (Deliver::App) the app you want to submit
    def submit_for_review!(app)
      begin
        verify_app(app)
        open_app_page(app)

        Helper.log("Submitting app for Review")

        click_on BUTTON_STRING_SUBMIT_FOR_REVIEW

        errors = (all(".pagemessage.error") || []).count > 0
        raise "Some error occured when submitting the app for review: '#{current_url}'" if errors

        return true
      rescue
        error_occured(ex)
      end
    end


    private
      def verify_app(app)
        raise ItunesConnectGeneralError.new("No valid Deliver::App given") unless app.kind_of?Deliver::App
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