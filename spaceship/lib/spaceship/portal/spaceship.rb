require_relative 'portal_client'
require_relative 'app_service'

module Spaceship
  module Portal
    class << self
      # This client stores the default client when using the lazy syntax
      # Spaceship.app instead of using the spaceship launcher
      attr_accessor :client

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
      # @return (Spaceship::Portal::Client) The client the login method was called for
      def login(user = nil, password = nil)
        @client = PortalClient.login(user, password)
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

      # @return (Class) Access the apps for the spaceship
      def app
        Spaceship::Portal::App.set_client(@client)
      end

      # @return (Class) Access the pass types for the spaceship
      def passbook
        Spaceship::Portal::Passbook.set_client(@client)
      end

      # @return (Class) Access the website pushes for the spaceship
      def website_push
        Spaceship::Portal::WebsitePush.set_client(@client)
      end

      # @return (Class) Access the app groups for the spaceship
      def app_group
        Spaceship::Portal::AppGroup.set_client(@client)
      end

      # @return (Class) Access app services for the spaceship
      def app_service
        Spaceship::Portal::AppService
      end

      # @return (Class) Access the devices for the spaceship
      def device
        Spaceship::Portal::Device.set_client(@client)
      end

      # @return (Class) Access the certificates for the spaceship
      def certificate
        Spaceship::Portal::Certificate.set_client(@client)
      end

      # @return (Class) Access the provisioning profiles for the spaceship
      def provisioning_profile
        Spaceship::Portal::ProvisioningProfile.set_client(@client)
      end

      # @return (Class) Access the merchants for the spaceship
      def merchant
        Spaceship::Portal::Merchant.set_client(@client)
      end
    end
  end

  # Legacy code to support `Spaceship.app` without `Portal`
  class << self
    def login(user = nil, password = nil)
      Spaceship::Portal.login(user, password)
    end

    def select_team
      Spaceship::Portal.select_team
    end

    def app
      Spaceship::Portal.app
    end

    def passbook
      Spaceship::Portal.passbook
    end

    def website_push
      Spaceship::Portal.website_push
    end

    def app_group
      Spaceship::Portal.app_group
    end

    def app_service
      Spaceship::Portal.app_service
    end

    def device
      Spaceship::Portal.device
    end

    def certificate
      Spaceship::Portal.certificate
    end

    def provisioning_profile
      Spaceship::Portal.provisioning_profile
    end

    def client
      Spaceship::Portal.client
    end

    def merchant
      Spaceship::Portal.merchant
    end
  end
end
