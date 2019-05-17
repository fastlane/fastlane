require_relative './base'
require_relative './models/model'

module Spaceship
  module ConnectAPI
    class Response
      attr_reader :body
      attr_reader :status

      def initialize(body: nil, status: nil)
        @body = body
        @status = status
      end

      def client
        return Spaceship::ConnectAPI::Base.client
      end

      def next_url
        return nil if body.nil?
        links = body["links"] || {}
        return links["next"]
      end

      def next_page
        url = next_url
        return nil if url.nil?
        return client.get(url)
      end

      def all_pages
        responses = [self]

        resp = self
        loop do
          resp = resp.next_page
          break if resp.nil?
          responses << resp
        end

        return responses
      end

      def models
        return [] if body.nil?
        return Spaceship::ConnectAPI::Models.parse(body)
      end
    end
  end
end
