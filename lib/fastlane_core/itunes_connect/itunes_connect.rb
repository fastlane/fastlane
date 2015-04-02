require 'capybara'
require 'capybara/poltergeist'
require 'credentials_manager/password_manager'
require 'phantomjs/poltergeist' # this will download and store phantomjs


require 'fastlane_core/itunes_connect/itunes_connect_helper.rb'
require 'fastlane_core/itunes_connect/itunes_connect_login.rb'
require 'fastlane_core/itunes_connect/itunes_connect_apple_id.rb'

module FastlaneCore
  # Everything that can't be achived using the {FastlaneCore::ItunesTransporter}
  # will be scripted using the iTunesConnect frontend.
  # 
  # Every method you call here, might take a time
  class ItunesConnect
    # This error occurs only if there is something wrong with the given login data
    class ItunesConnectLoginError < StandardError 
    end

    # This error can occur for many reaons. It is
    # usually raised when an UI element could not be found
    class ItunesConnectGeneralError < StandardError
    end

    include Capybara::DSL

    ITUNESCONNECT_URL = "https://itunesconnect.apple.com/"
    APP_DETAILS_URL = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/[[app_id]]"

    BUTTON_STRING_NEW_VERSION = "New Version"
    BUTTON_STRING_SUBMIT_FOR_REVIEW = "Submit for Review"

    WAITING_FOR_REVIEW = "Waiting For Review"
    
    def initialize
      super

      return if Helper.is_test?
      
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
          phantomjs: Phantomjs.path,
          phantomjs_options: conf,
          phantomjs_logger: File.open("/tmp/poltergeist_log.txt", "a"),
          js_errors: false,
          timeout: 90
        })
      end

      page.driver.headers = { "Accept-Language" => "en" }

      login
    end
  end
end
