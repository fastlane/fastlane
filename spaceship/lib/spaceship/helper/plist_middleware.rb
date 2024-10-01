require 'faraday'

module Faraday
  module DecodePlist
    # Faraday middleware for decoding XML requests.
    class Middleware < Faraday::Middleware
      def initialize(app = nil, content_type: /\bplist$/)
        super(app)
        @content_types = Array(content_type)
      end

      # @param env [Faraday::Env] the environment of the response being processed.
      def on_complete(env)
        process_response(env) if process_response_type?(response_type(env)) && parse_response?(env)
      end

      private

      def process_response(env)
        env.body = parse(env.body)
      rescue Faraday::ParsingError => e
        raise Faraday::ParsingError.new(e.wrapped_exception, env[:response])
      end

      def parse(body)
        require 'plist' unless Object.const_defined?(:Plist)
        body = body.force_encoding("UTF-8")
        Plist.parse_xml(body)
      rescue StandardError, SyntaxError => e
        raise e if e.kind_of?(SyntaxError)

        raise Faraday::ParsingError, e
      end

      def response_type(env)
        env.response_headers["Content-Type"].to_s.split(";", 2).first.to_s
      end

      def process_response_type?(type)
        @content_types.empty? ||
          @content_types.any? { |pattern| pattern.kind_of?(Regexp) ? type.match?(pattern) : type == pattern }
      end

      def parse_response?(env)
        env.body.respond_to?(:to_str)
      end
    end
  end
end

Faraday::Response.register_middleware(plist: Faraday::DecodePlist::Middleware)
