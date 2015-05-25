module Spaceship
  class Launcher
    attr_accessor :client

    # Create a new spaceship client
    # @param user (String) (optional): Username
    # @param password (String) (optional): Password
    def initialize(user = nil, password = nil)
      @client = Client.new
      @client.login(user, password)
    end

    # Login Helper

    # Login using username and password
    # @param user (String): Username
    # @param password (String): Password
    def login(user, password) 
      @client.login(user, password)
    end

    # Open up the team selection for the user (if necessary).
    # 
    # If the user is in multiple teams, a team selection is shown.
    # The user can then select a team by entering the number
    # 
    # Additionally, the team ID is shown next to each team name
    # so that the user can use the environment variable `FASTLANE_TEAM_ID`
    # for future user.
    # 
    # @return (String) The ID of the select team. You also get the value if 
    #   the user is only in one team.
    def select_team
      @client.select_team
    end

    # Helper methods for managing multiple instances of spaceship

    # @return (Class) Access the apps for this spaceship
    def app
      Spaceship::App.set_client(@client)
    end

    # @return (Class) Access the devices for this spaceship
    def device
      Spaceship::Device.set_client(@client)
    end

    # @return (Class) Access the certificates for this spaceship
    def certificate
      Spaceship::Certificate.set_client(@client)
    end

    # @return (Class) Access the provisioning profiles for this spaceship
    def provisioning_profile
      Spaceship::ProvisioningProfile.set_client(@client)
    end
  end
end