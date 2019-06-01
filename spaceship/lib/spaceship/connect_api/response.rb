require_relative './base'
require_relative './models/model'

module Spaceship
  module ConnectAPI
    class Response
      include Enumerable
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

      def next_pages(count: 1)
        if !count.nil? && count < 0
          count = 0
        end

        responses = [self]
        counter = 0

        resp = self
        loop do
          resp = resp.next_page
          break if resp.nil?
          responses << resp
          counter += 1

          break if !count.nil? && counter >= count
        end

        return responses
      end

      def all_pages
        return next_pages(count: nil)
      end

      def to_models
        return [] if body.nil?
        model_or_models = Spaceship::ConnectAPI::Models.parse(body)
        return [model_or_models].flatten
      end

      def each(&block)
        to_models.each do |model|
          yield(model)
        end
      end
    end
  end
end
