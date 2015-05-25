require 'spaceship/version'
require 'fastlane_core'
require 'spaceship/base'
require 'spaceship/client'
require 'spaceship/profile_types'
require 'spaceship/app'
require 'spaceship/certificate'
require 'spaceship/device'
require 'spaceship/provisioning_profile'

module Spaceship
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config, :client

    def login(username = nil, password = nil)
      if !username or !password
        require 'credentials_manager'
        data = CredentialsManager::PasswordManager.shared_manager(username, false)
        username ||= data.username
        password ||= data.password
      end

      @client = Client.login(username, password)
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  # FastlaneCore::UpdateChecker.verify_latest_version('spaceship', Spaceship::VERSION)

  class Control

    attr_accessor :client

    def initialize
      @client = Client.new
    end

    ## helper methods for managing multiple instances of spaceship

    ##
    #
    def app
      Spaceship::App.set_client(@client)
    end

    def device
      Spaceship::Device.set_client(@client)
    end

    def certificate
      Spaceship::Certificate.set_client(@client)
    end

    def provisioning_profile
      Spaceship::ProvisioningProfile.set_client(@client)
    end
  end
end
