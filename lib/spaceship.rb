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
      @client = Client.login(username, password)
    end

    # Helper methods for managing multiple instances of spaceship

    # @return (Class) Access the apps for the spaceship
    def app
      Spaceship::App.set_client(@client)
    end

    # @return (Class) Access the devices for the spaceship
    def device
      Spaceship::Device.set_client(@client)
    end

    # @return (Class) Access the certificates for the spaceship
    def certificate
      Spaceship::Certificate.set_client(@client)
    end

    # @return (Class) Access the provisioning profiles for the spaceship
    def provisioning_profile
      Spaceship::ProvisioningProfile.set_client(@client)
    end
  end
end
