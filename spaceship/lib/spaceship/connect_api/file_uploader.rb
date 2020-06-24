require 'faraday' # HTTP Client
require 'faraday-cookie_jar'
require 'faraday_middleware'

module Spaceship
  class ConnectAPI
    module FileUploader
      def self.upload(upload_operation, payload)
        # {
        #   "method": "PUT",
        #   "url": "https://some-url-apple-gives-us",
        #   "length": 57365,
        #   "offset": 0,
        #   "requestHeaders": [
        #     {
        #       "name": "Content-Type",
        #       "value": "image/png"
        #     }
        #   ]
        # }

        headers = {}
        upload_operation["requestHeaders"].each do |hash|
          headers[hash["name"]] = hash["value"]
        end

        client.send(
          upload_operation["method"].downcase,
          upload_operation["url"],
          payload,
          headers
        )
      end

      def self.client
        options = {
          request: {
              timeout: (ENV["SPACESHIP_TIMEOUT"] || 300).to_i,
              open_timeout: (ENV["SPACESHIP_TIMEOUT"] || 300).to_i
            }
        }

        @client ||= Faraday.new(options) do |c|
          c.response(:json, content_type: /\bjson$/)
          c.response(:xml, content_type: /\bxml$/)
          c.response(:plist, content_type: /\bplist$/)
          c.adapter(Faraday.default_adapter)

          if ENV['SPACESHIP_DEBUG']
            # for debugging only
            # This enables tracking of networking requests using Charles Web Proxy
            c.proxy = "https://127.0.0.1:8888"
            c.ssl[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
          elsif ENV["SPACESHIP_PROXY"]
            c.proxy = ENV["SPACESHIP_PROXY"]
            c.ssl[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if ENV["SPACESHIP_PROXY_SSL_VERIFY_NONE"]
          end

          if ENV["DEBUG"]
            puts("To run spaceship through a local proxy, use SPACESHIP_DEBUG")
          end
        end
      end
    end
  end
end
