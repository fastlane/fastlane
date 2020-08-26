require_relative './token'
require_relative './provisioning/provisioning'
require_relative './testflight/testflight'
require_relative './tunes/tunes'
require_relative './users/users'

module Spaceship
  class ConnectAPI
    class Client
      attr_accessor :tunes_client
      attr_accessor :portal_client

      # Initializes client with Apple's App Store Connect JWT auth key.
      #
      # This method will automatically use the key id, issuer id, and filepath from environment
      # variables if not given.
      #
      # All three parameters are needed to authenticate.
      #
      # @param key_id (String) (optional): The key id
      # @param issuer_id (String) (optional): The issuer id
      # @param filepath (String) (optional): The filepath
      #
      # @raise InvalidUserCredentialsError: raised if authentication failed
      #
      # @return (Spaceship::ConnectAPI::Client) The client the login method was called for
      def self.auth(key_id: nil, issuer_id: nil, filepath: nil)
        token = Spaceship::ConnectAPI::Token.create(key_id: key_id, issuer_id: issuer_id, filepath: filepath)
        return ConnectAPI::Client.new(token: token)
      end

      # Authenticates with Apple's web services. This method has to be called once
      # to generate a valid session.
      #
      # This method will automatically use the username from the Appfile (if available)
      # and fetch the password from the Keychain (if available)
      #
      # @param user (String) (optional): The username (usually the email address)
      # @param password (String) (optional): The password
      # @param team_id (String) (optional): The team id
      # @param team_name (String) (optional): The team name
      #
      # @raise InvalidUserCredentialsError: raised if authentication failed
      #
      # @return (Spaceship::ConnectAPI::Client) The client the login method was called for
      def self.login(user = nil, password = nil, team_id: nil, team_name: nil)
        tunes_client = TunesClient.login(user, password)
        portal_client = PortalClient.login(user, password)

        # The clients will automatically select the first team if none is given
        if !team_id.nil? || !team_name.nil?
          tunes_client.select_team(team_id: team_id, team_name: team_name)
          portal_client.select_team(team_id: team_id, team_name: team_name)
        end

        return ConnectAPI::Client.new(tunes_client: tunes_client, portal_client: portal_client)
      end

      def initialize(cookie: nil, current_team_id: nil, token: nil, tunes_client: nil, portal_client: nil)
        # If using web session...
        # Spaceship::Tunes is needed for TestFlight::API, Tunes::API, and Users::API
        # Spaceship::Portal is needed for Provisioning::API
        @tunes_client = tunes_client
        @portal_client = portal_client

        # Extending this instance to add API endpoints from these modules
        # Each of these modules adds a new setter method for an instance
        # of an ConnectAPI::APIClient
        # These get set in set_indvidual_clients
        self.extend(Spaceship::ConnectAPI::TestFlight::API)
        self.extend(Spaceship::ConnectAPI::Tunes::API)
        self.extend(Spaceship::ConnectAPI::Provisioning::API)
        self.extend(Spaceship::ConnectAPI::Users::API)

        set_indvidual_clients(
          cookie: cookie,
          current_team_id: current_team_id,
          token: token,
          tunes_client: @tunes_client,
          portal_client: @portal_client
        )
      end

      def select_team(team_id: nil, team_name: nil)
        @tunes_client.select_team(team_id: team_id, team_name: team_name)
        @portal_client.select_team(team_id: team_id, team_name: team_name)

        # Updating the tunes and portal clients requires resetting
        # of the clients in the API modules
        set_indvidual_clients(
          cookie: nil,
          current_team_id: nil,
          token: nil,
          tunes_client: tunes_client,
          portal_client: portal_client
        )
      end

      private

      def set_indvidual_clients(cookie: nil, current_team_id: nil, token: nil, tunes_client: nil, portal_client: nil)
        # This was added by Spaceship::ConnectAPI::TestFlight::API and is required
        # to be set for API methods to have a client to send request on
        if cookie || token || tunes_client
          self.test_flight_request_client = Spaceship::ConnectAPI::TestFlight::Client.new(
            cookie: cookie,
            current_team_id: current_team_id,
            token: token,
            another_client: tunes_client
          )
        end

        # This was added by Spaceship::ConnectAPI::Tunes::API and is required
        # to be set for API methods to have a client to send request on
        if cookie || token || tunes_client
          self.tunes_request_client = Spaceship::ConnectAPI::Tunes::Client.new(
            cookie: cookie,
            current_team_id: current_team_id,
            token: token,
            another_client: tunes_client
          )
        end

        # This was added by Spaceship::ConnectAPI::Provisioning::API and is required
        # to be set for API methods to have a client to send request on
        if cookie || token || portal_client
          self.provisioning_request_client = Spaceship::ConnectAPI::Provisioning::Client.new(
            cookie: cookie,
            current_team_id: current_team_id,
            token: token,
            another_client: portal_client
          )
        end

        # This was added by Spaceship::ConnectAPI::Users::API and is required
        # to be set for API methods to have a client to send request on
        if cookie || token || tunes_client
          self.users_request_client = Spaceship::ConnectAPI::Users::Client.new(
            cookie: cookie,
            current_team_id: current_team_id,
            token: token,
            another_client: tunes_client
          )
        end
      end
    end
  end
end
