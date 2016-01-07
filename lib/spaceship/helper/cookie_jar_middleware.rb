require 'cookiejar'

module Faraday
  class CookieJar < Faraday::Middleware
    def initialize(app, options = {})
      super(app)
      @jar = options[:jar] || CookieJar::Jar.new
    end

    def call(env)
      cookies = @jar.get_cookies(env[:url])

      unless cookies.empty?
        if env[:request_headers]["Cookie"]
          env[:request_headers]["Cookie"] = @jar.get_cookie_header(env[:url]) + ";" + env[:request_headers]["Cookie"]
        else
          env[:request_headers]["Cookie"] = @jar.get_cookie_header(env[:url])
        end
      end

      @app.call(env).on_complete do |res|
        if res[:response_headers]
          @jar.set_cookies_from_headers(env[:url], res[:response_headers])
        end
      end
    end
  end
end

if Faraday.respond_to?(:register_middleware)
  Faraday.register_middleware cookie_jar: -> { Faraday::CookieJar }
elsif Faraday::Middleware.respond_to?(:register_middleware)
  Faraday::Middleware.register_middleware cookie_jar: Faraday::CookieJar
end
