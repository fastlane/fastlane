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
    
    def initialize
      super
      
      Capybara.default_driver = :poltergeist

      self.login
    end

    def login(user = nil, password = nil)
      Helper.debug_log "Logging into iTunesConnect"

      host = "itunesconnect.apple.com"

      user ||= PasswordManager.new.username
      password ||= PasswordManager.new.password

      visit ITUNESCONNECT_URL
      fill_in "accountname", with: user
      fill_in "accountpassword", with: password

      wait_for_elements(".enabled").first.click

      wait_for_elements('.ng-scope.managedWidth')

      page.save_screenshot "loggedIn.png"

      Helper.debug_log "Successfully logged into iTunesConnect"
      true
    end

    def open_app_page(app)
      Helper.debug_log "Opening detail page for app #{app}"

      visit APP_DETAILS_URL.gsub("[[app_id]]", app.apple_id.to_s)

      wait_for_elements('.page-subnav')

      true
    end

    def create_new_version(app, version_number)
      # TODO: Check if there was already a new version created
      
      click_on "New Version"

      all(".fullWidth.nobottom.ng-isolate-scope.ng-pristine").last.set(version_number.to_s)
      click_on "Create"

      true
    end



    # Helper - move out

    def wait_for_elements(name)
      counter = 0
      results = all(name)
      while results.count == 0      
        Helper.debug_log "Waiting for #{name}"
        sleep 0.2

        results = all(name)

        counter += 1
        if counter > 100
          Helper.debug_log page.html
          puts caller
          raise "Couldn't find element '#{name}' after waiting for quite some time"
        end
      end
      return results
    end
  end
end