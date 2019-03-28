require 'faraday_middleware/response_middleware'

module FaradayMiddleware
  class PlistMiddleware < ResponseMiddleware
    dependency { require 'plist' unless Object.const_defined?('Plist') }

    define_parser do |body|
      body = body.force_encoding('UTF-8')
      Plist.parse_xml(body)
    end
  end
end

Faraday::Response.register_middleware(plist: FaradayMiddleware::PlistMiddleware)
