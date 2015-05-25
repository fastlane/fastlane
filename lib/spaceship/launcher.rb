module Spaceship
  class Launcher
    attr_accessor :client

    def initialize
      @client = Client.new
    end

    # Login Helper
    def login(user, password) 
      @client.login(user, password)
    end

    def select_team
      @client.select_team
    end

    ## helper methods for managing multiple instances of spaceship

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