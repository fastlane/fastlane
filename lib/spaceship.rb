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

    def apps
      App.all
    end

    def certificates
      Certificate.all
    end

    def devices
      Device.all
    end

    def provisioning_profiles
      ProvisioningProfile.all
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  # FastlaneCore::UpdateChecker.verify_latest_version('spaceship', Spaceship::VERSION)
end
