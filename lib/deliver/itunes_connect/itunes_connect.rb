require 'capybara'
require 'capybara/poltergeist'
require 'fastimage'
require 'credentials_manager/password_manager'

# Import all the actions
require 'deliver/itunes_connect/itunes_connect_submission'
require 'deliver/itunes_connect/itunes_connect_reader'
require 'deliver/itunes_connect/itunes_connect_helper'
require 'deliver/itunes_connect/itunes_connect_new_version'
require 'deliver/itunes_connect/itunes_connect_login'

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

    WAITING_FOR_REVIEW = "Waiting For Review"
    PROCESSING_TEXT = "Processing"
    
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

      login
    end
  end
end
