require 'credentials_manager/password_manager'
require 'open-uri'

require 'capybara'
require 'capybara/poltergeist'
require 'phantomjs/poltergeist'

require 'fastlane_core/developer_center/developer_center_login'
require 'fastlane_core/developer_center/developer_center_helper'

module FastlaneCore
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
    PROFILES_URL = "https://developer.apple.com/account/ios/profile/profileList.action?type=production"
    TMP_FOLDER = "/tmp/fastlane_core/"

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
          js_errors: false,
          timeout: 90
        })
      end

      page.driver.headers = { "Accept-Language" => "en" }

      self.login
    end
  end
end
