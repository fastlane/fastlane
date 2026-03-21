require 'faraday'

require_relative 'globals'

module Spaceship
  class StatsMiddleware < Faraday::Middleware
    ServiceOption = Struct.new(:name, :url, :auth_type)
    URLLog = Struct.new(:url, :auth_type)
    class << self
      def services
        return @services if @services

        require_relative 'tunes/tunes_client'
        require_relative 'portal/portal_client'
        require_relative 'connect_api/testflight/client'
        require_relative 'connect_api/provisioning/client'

        @services ||= [
          ServiceOption.new("App Store Connect API (official)", "api.appstoreconnect.apple.com", "JWT"),
          ServiceOption.new("App Store Connect API (web session)", Spaceship::ConnectAPI::TestFlight::Client.hostname.gsub("https://", ""), "Web session"),
          ServiceOption.new("Enterprise Program API (official)", "api.enterprise.developer.apple.com", "JWT"),
          ServiceOption.new("Legacy iTunesConnect Auth", "idmsa.apple.com", "Web session"),
          ServiceOption.new("Legacy iTunesConnect Auth", "appstoreconnect.apple.com/olympus/v1/", "Web session"),
          ServiceOption.new("Legacy iTunesConnect", Spaceship::TunesClient.hostname.gsub("https://", ""), "Web session"),
          ServiceOption.new("Legacy iTunesConnect Developer Portal", Spaceship::PortalClient.hostname.gsub("https://", ""), "Web session"),
          ServiceOption.new("App Store Connect API (web session)", Spaceship::ConnectAPI::Provisioning::Client.hostname.gsub("https://", ""), "Web session")
        ]
      end

      def service_stats
        @service_stats ||= Hash.new(0)
      end

      def request_logs
        @request_logs ||= []
        @request_logs
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
      return false unless env && env.url && (uri = URI.parse(env.url.to_s))
      service = StatsMiddleware.services.find do |s|
        uri.to_s.include?(s.url)
      end

      service = ServiceOption.new("Unknown", uri.host, "Unknown") if service.nil?
      StatsMiddleware.service_stats[service] += 1

      StatsMiddleware.request_logs << URLLog.new(uri.to_s, service.auth_type)

      return true
    rescue => e
      puts("Failed to log spaceship stats - #{e.message}") if Spaceship::Globals.verbose?
      return false
    end
  end
end
