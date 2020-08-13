require 'faraday'

module Spaceship
  class StatLogger < Faraday::Middleware
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
      if env && env.url && (uri = URI(env.url))
        log(uri)
      end
      @app.call(env)
    end

    def log(uri)
      service = StatLogger.services.find do |s|
        uri.to_s.include?(s.url)
      end

      if service.nil?
        service = ServiceOption.new("", uri.host, "")
      end

      StatLogger.service_stats[service] += 1
    end
  end
end
