require 'faraday'

require_relative 'token'
require_relative '../globals'

module Spaceship
  class TokenRefreshMiddleware < Faraday::Middleware
    def initialize(app, token)
      @token = token
      super(app)
    end

    def call(env)
      if @token.expired?
        puts("App Store Connect API token expired at #{@token.expiration}... refreshing") if Spaceship::Globals.verbose?
        @token.refresh!
      end

      env.request_headers["Authorization"] = "Bearer #{@token.text}"

      @app.call(env)
    end
  end
end
