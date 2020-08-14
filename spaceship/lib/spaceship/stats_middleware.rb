require 'faraday'

require_relative 'globals'

module Spaceship
  class StatsMiddleware < Faraday::Middleware
    ServiceOption = Struct.new(:name, :url, :auth_type)
    class << self
      def services
        @services ||= [
          ServiceOption.new("App Store Connect API (official)", "api.appstoreconnect.apple.com", "JWT"),
          ServiceOption.new("App Store Connect API (web session)", "appstoreconnect.apple.com/iris/v1", "Web session"),
          ServiceOption.new("App Store Connect API (web session)", "developer.apple.com/services-account/v1/", "Web session"),
          ServiceOption.new("Legacy iTunesConnect Auth", "idmsa.apple.com", "Web session"),
          ServiceOption.new("Legacy iTunesConnect Auth", "appstoreconnect.apple.com/olympus/v1/", "Web session"),
          ServiceOption.new("Legacy iTunesConnect", "appstoreconnect.apple.com/WebObjects/iTunesConnect.woa", "Web session"),
          ServiceOption.new("Legacy iTunesConnect Developer Portal", "developer.apple.com/services-account", "Web session")
        ]

        @services
      end

      def service_stats
        @service_stats ||= Hash.new(0)
        @service_stats
      end
    end

    def initialize(app)
      super(app)
    end

    def call(env)
      log(env)
      @app.call(env)
    end

    def log(env)
      return false unless env && env.url && (uri = URI.parse(env.url))
      service = StatsMiddleware.services.find do |s|
        uri.to_s.include?(s.url)
      end

      service = ServiceOption.new("", uri.host, "") if service.nil?
      StatsMiddleware.service_stats[service] += 1

      return true
    rescue => e
      puts("Failed to log spaceship stats - #{e.message}") if Spaceship::Globals.verbose?
      return false
    end
  end
end
