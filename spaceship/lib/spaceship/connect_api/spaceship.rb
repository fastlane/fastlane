module Spaceship
  class ConnectAPI
    class << self
      # This client stores the default client when using the lazy syntax
      # Spaceship.app instead of using the spaceship launcher
      attr_accessor :tunes_client
      attr_accessor :client

      def auth(key_id: nil, issuer_id: nil, filepath: nil)
        token = Spaceship::ConnectAPI::Token.create(key_id: key_id, issuer_id: issuer_id, filepath: filepath)
        @client = ConnectAPI::Client.new(token: token)
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
        @tunes_client = TunesClient.login(user, password)
        @tunes_client.select_team(team_id: team_id, team_name: team_name)
        @client = ConnectAPI::Client.new(another_client: @tunes_client)
      end

      # Open up the team selection for the user (if necessary).
      #
      # If the user is in multiple teams, a team selection is shown.
      # The user can then select a team by entering the number
      #
      # @param team_id (String) (optional): The ID of an App Store Connect team
      # @param team_name (String) (optional): The name of an App Store Connect team
      def select_team(team_id: nil, team_name: nil)
        raise "Not used for now"
        # @tunes_client.select_team(team_id: team_id, team_name: team_name)
      end
    end
  end
end
