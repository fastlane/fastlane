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
    
    def initialize
      super
      
      Capybara.default_driver = :poltergeist
    end

    def login(user = nil, password = nil)
      host = "itunesconnect.apple.com"

      user ||= PasswordManager.new.username
      password ||= PasswordManager.new.password

      visit ITUNESCONNECT_URL
      fill_in "accountname", with: user
      fill_in "accountpassword", with: password

      wait_for_elements(".enabled").first.click

      wait_for_elements('.ng-scope.managedWidth')

      page.save_screenshot "loggedIn.png"

      debug_log "Successfully logged in"
      true
    end

    # Helper - move out

    def wait_for_elements(name)
      counter = 0
      results = all(name)
      while results.count == 0      
        debug_log "Waiting for #{name}"
        sleep 0.2

        results = all(name)

        counter += 1
        if counter > 100
          debug_log page.html
          raise "Couldn't find element '#{name}'"
        end
      end
      return results
    end


    def debug_log(str)
      puts str
    end
  end
end