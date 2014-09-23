require 'ios_deploy_kit/password_manager'

require 'capybara'
require 'capybara/poltergeist'
require 'security'

# TODO: Dev only
require 'pry'


module IosDeployKit
  class ItunesConnect
    include Capybara::DSL

    ITUNESCONNECT_URL = "https://itunesconnect.apple.com"
    APP_DETAILS_URL = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/[[app_id]]"

    BUTTON_STRING_NEW_VERSION = "New Version"
    BUTTON_STRING_SUBMIT_FOR_REVIEW = "Submit for Review"
    
    def initialize
      super
      
      Capybara.default_driver = :poltergeist

      self.login
    end

    def login(user = nil, password = nil)
      Helper.log.info "Logging into iTunesConnect"

      host = "itunesconnect.apple.com"

      user ||= PasswordManager.new.username
      password ||= PasswordManager.new.password

      visit ITUNESCONNECT_URL
      fill_in "accountname", with: user
      fill_in "accountpassword", with: password

      begin
        wait_for_elements(".enabled").first.click
        wait_for_elements('.ng-scope.managedWidth')
      rescue
        raise "Error logging in user #{user} with the given password. Make sure you set them correctly"
      end

      Helper.log.info "Successfully logged into iTunesConnect"
      true
    end

    def open_app_page(app)
      Helper.log.info "Opening detail page for app #{app}"

      visit APP_DETAILS_URL.gsub("[[app_id]]", app.apple_id.to_s)

      wait_for_elements('.page-subnav')

      true
    end

    def get_app_status(app)
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
    def create_new_version!(app, version_number)
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



    # Helper - move out

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
          raise "Couldn't find element '#{name}' after waiting for quite some time"
        end
      end
      return results
    end
  end
end