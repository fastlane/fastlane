require_relative 'portal/portal_client'

module Spaceship
  class Launcher
    attr_accessor :client

    # Launch a new spaceship, which can be used to maintain multiple instances of
    # spaceship. You can call `.new` without any parameters, but you'll have to call
    # `.login` at a later point. If you prefer, you can pass the login credentials
    # here already.
    #
    # Authenticates with Apple's web services. This method has to be called once
    # to generate a valid session. The session will automatically be used from then
    # on.
    #
    # This method will automatically use the username from the Appfile (if available)
    # and fetch the password from the Keychain (if available)
    #
    # @param user (String) (optional): The username (usually the email address)
    # @param password (String) (optional): The password
    #
    # @raise InvalidUserCredentialsError: raised if authentication failed
    def initialize(user = nil, password = nil)
      @client = PortalClient.new

      if user || password
        @client.login(user, password)
      end
    end

    #####################################################
    # @!group Login Helper
    #####################################################

    # Authenticates with Apple's web services. This method has to be called once
    # to generate a valid session. The session will automatically be used from then
    # on.
    #
    # This method will automatically use the username from the Appfile (if available)
    # and fetch the password from the Keychain (if available)
    #
    # @param user (String) (optional): The username (usually the email address)
    # @param password (String) (optional): The password
    #
    # @raise InvalidUserCredentialsError: raised if authentication failed
    #
    # @return (Spaceship::Client) The client the login method was called for
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
    # @param team_id (String) (optional): The ID of a Developer Portal team
    # @param team_name (String) (optional): The name of a Developer Portal team
    #
    # @return (String) The ID of the select team. You also get the value if
    #   the user is only in one team.
    def select_team(team_id: nil, team_name: nil)
      @client.select_team(team_id: team_id, team_name: team_name)
    end

    #####################################################
    # @!group Helper methods for managing multiple instances of spaceship
    #####################################################

    # @return (Class) Access the apps for this spaceship
    def app
      Spaceship::Portal::App.set_client(@client)
    end

    # @return (Class) Access the app groups for this spaceship
    def app_group
      Spaceship::Portal::AppGroup.set_client(@client)
    end

    # @return (Class) Access the devices for this spaceship
    def device
      Spaceship::Portal::Device.set_client(@client)
    end

    # @return (Class) Access the certificates for this spaceship
    def certificate
      Spaceship::Portal::Certificate.set_client(@client)
    end

    # @return (Class) Access the provisioning profiles for this spaceship
    def provisioning_profile
      Spaceship::Portal::ProvisioningProfile.set_client(@client)
    end
  end
end
