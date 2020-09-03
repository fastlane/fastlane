require 'faraday' # HTTP Client
require 'faraday-cookie_jar'
require 'faraday_middleware'

require 'spaceship/globals'

require 'openssl'

module Spaceship
  class ConnectAPI
    module FileUploader
      def self.upload(upload_operations, bytes)
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

        upload_operations.each_with_index do |upload_operation, index|
          headers = {}
          upload_operation["requestHeaders"].each do |hash|
            headers[hash["name"]] = hash["value"]
          end

          offset = upload_operation["offset"]
          length = upload_operation["length"]

          puts("Uploading file (part #{index + 1})...") if Spaceship::Globals.verbose?
          with_retry do
            client.send(
              upload_operation["method"].downcase,
              upload_operation["url"],
              bytes[offset, length],
              headers
            )
          end
        end
        puts("Uploading complete!") if Spaceship::Globals.verbose?
      end

      def self.with_retry(tries = 5, &_block)
        tries = 1 if Object.const_defined?("SpecHelper")
        response = yield

        tries -= 1

        unless (200...300).cover?(response.status)
          msg = "Received status of #{response.status}! Retrying after 3 seconds (remaining: #{tries})..."
          raise msg
        end

        return response
      rescue => error
        puts(error) if Spaceship::Globals.verbose?
        if tries.zero?
          raise "Failed to upload file after retries... Received #{response.status}"
        else
          retry
        end
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
