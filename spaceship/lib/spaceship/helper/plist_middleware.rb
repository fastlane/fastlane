require 'faraday'

module Spaceship
  class PlistMiddleware < Faraday::Middleware
    def on_complete(env)
      process_response(env) if parse_response?(env)
    end

    private

    def process_response(env)
      env.body = parse(env.body)
    end

    def parse(body)
      require 'plist' unless Object.const_defined?("Plist")
      Plist.parse_xml(body.force_encoding("UTF-8"))
    rescue StandardError, SyntaxError => e
      raise Faraday::ParsingError.new(e, env)
    end

    def parse_response?(env)
      env.body.kind_of?(String) && process_response_type?(env) && env.parse_body?
    end

    def process_response_type?(env)
      type = response_type(env)
      content_types.empty? || content_types.any? do |pattern|
        pattern.kind_of?(Regexp) ? type.match?(pattern) : type == pattern
      end
    end

    def response_type(env)
      type = env.response_headers['Content-Type'].to_s
      type = type.split(';', 2).first if type.index(';')
      type
    end

    def content_types
      @content_types ||= Array(options[:content_type])
    end
  end
end

Faraday::Response.register_middleware(plist: Spaceship::PlistMiddleware)
