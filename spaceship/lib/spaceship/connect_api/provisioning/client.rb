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
          # The App Store Connect API is only available in a web session through a
          # a proxy server where GET requests are actually sent as a POST
          return get_as_post(url_or_path, params) if web_session?

          super(url_or_path, params)
        end

        def get_as_post(url_or_path, params = nil)
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
      end
    end
  end
end
