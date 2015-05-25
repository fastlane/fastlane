require 'spaceship/version'
require 'spaceship/base'
require 'spaceship/client'
require 'spaceship/profile_types'
require 'spaceship/app'
require 'spaceship/certificate'
require 'spaceship/device'
require 'spaceship/provisioning_profile'
require 'spaceship/launcher'

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
end
