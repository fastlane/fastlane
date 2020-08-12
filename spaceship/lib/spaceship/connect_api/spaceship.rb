require_relative './client'

require_relative './testflight/testflight'

module Spaceship
  class ConnectAPI
    class << self
      # This client stores the global client when using the lazy syntax
      attr_accessor :client

      # Forward class calls to the global client
      extend(Forwardable)
      def_delegators(:client, *Spaceship::ConnectAPI::Provisioning::API.instance_methods(false))
      def_delegators(:client, *Spaceship::ConnectAPI::TestFlight::API.instance_methods(false))
      def_delegators(:client, *Spaceship::ConnectAPI::Tunes::API.instance_methods(false))
      def_delegators(:client, *Spaceship::ConnectAPI::Users::API.instance_methods(false))

      # def method_missing(m, *args, &block)
      #   # This forwards lazy class calls onto the client
      #   if client.respond_to?(m)
      #     return client.send(m, *args, &block)
      #   end
      #   raise ArgumentError, "Method `#{m}` doesn't exist."
      # end

      def auth(key_id: nil, issuer_id: nil, filepath: nil)
        @client = ConnectAPI::Client.auth(key_id: key_id, issuer_id: issuer_id, filepath: filepath)
      end

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
      def login(user = nil, password = nil, team_id: nil, team_name: nil)
        @client = ConnectAPI::Client.login(user, password, team_id: team_id, team_name: team_name)
      end

      # Open up the team selection for the user (if necessary).
      #
      # If the user is in multiple teams, a team selection is shown.
      # The user can then select a team by entering the number
      #
      # @param team_id (String) (optional): The ID of an App Store Connect team
      # @param team_name (String) (optional): The name of an App Store Connect team
      def select_team(team_id: nil, team_name: nil)
        @client.select_team(team_id: team_id, team_name: team_name)
      end
    end
  end
end
