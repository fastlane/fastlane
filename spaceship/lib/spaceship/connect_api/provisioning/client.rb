require_relative '../client'
require_relative '../../portal/portal_client'

module Spaceship
  class ConnectAPI
    module Provisioning
      class Client < Spaceship::ConnectAPI::Client
        def self.instance
          # Verify there is a token or a client that can be used
          if Spaceship::ConnectAPI.token
            if @client.nil? || @client.token != Spaceship::ConnectAPI.token
              @client = Spaceship::ConnectAPI::Provisioning::Client.new(token: Spaceship::ConnectAPI.token)
            end
          elsif Spaceship::Portal.client
            # Initialize new client if new or if team changed
            if @client.nil? || @client.team_id != Spaceship::Portal.client.team_id
              @client = Spaceship::ConnectAPI::Provisioning::Client.client_with_authorization_from(Spaceship::Portal.client)
            end
          end

          # Need to handle not having a client but this shouldn't ever happen
          raise "Please login using `Spaceship::Portal.login('user', 'password')`" unless @client

          @client
        end

        def self.hostname
          'https://developer.apple.com/services-account/v1/'
        end

        #
        # Helpers
        #

        def get(url_or_path, params = nil)
          # The Provisioning App Store Connect API needs to be proxied through a 
          # POST request if using web session
          return proxy_get(url_or_path, params) if web_session?

          super(url_or_path, params)
        end

        def post(url_or_path, body)
          # The Provisioning App Store Connect API needs teamId added to the body of
          # each post if using web session
          return proxy_post(url_or_path, body) if web_session?

          super(url_or_path, body)
        end

        def proxy_get(url_or_path, params = nil)
          encoded_params = Faraday::NestedParamsEncoder.encode(params)
          body = { "urlEncodedQueryParams" => encoded_params, "teamId" => team_id }

          response = request(:post) do |req|
            req.url(url_or_path)
            req.body = body.to_json
            req.headers['Content-Type'] = 'application/vnd.api+json'
            req.headers['X-HTTP-Method-Override'] = 'GET'
            req.headers['X-Requested-With'] = 'XMLHttpRequest'
          end
          handle_response(response)
        end

        def proxy_post(url_or_path, body)
          body[:data][:attributes][:teamId] = team_id

          response = request(:post) do |req|
            req.url(url_or_path)
            req.body = body.to_json
            req.headers['Content-Type'] = 'application/vnd.api+json'
            req.headers['X-Requested-With'] = 'XMLHttpRequest'
          end
          handle_response(response)
        end
      end
    end
  end
end
