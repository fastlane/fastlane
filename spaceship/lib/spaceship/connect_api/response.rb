require_relative './model'

module Spaceship
  class ConnectAPI
    class Response
      include Enumerable
      attr_reader :body
      attr_reader :status
      attr_reader :headers
      attr_reader :client

      def initialize(body: nil, status: nil, headers: nil, client: nil)
        @body = body
        @status = status
        @headers = headers
        @client = client
      end

      def next_url
        return nil if body.nil?
        links = body["links"] || {}
        return links["next"]
      end

      def next_page(&block)
        url = next_url
        return nil if url.nil?
        if block_given?
          return yield(url)
        else
          return client.get(url)
        end
      end

      def next_pages(count: 1, &block)
        if !count.nil? && count < 0
          count = 0
        end

        responses = [self]
        counter = 0

        resp = self
        loop do
          resp = resp.next_page(&block)
          break if resp.nil?
          responses << resp
          counter += 1

          break if !count.nil? && counter >= count
        end

        return responses
      end

      def all_pages(&block)
        return next_pages(count: nil, &block)
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

      def all_pages_each(&block)
        to_models.each do |model|
          yield(model)
        end

        resp = self
        loop do
          resp = resp.next_page
          break if resp.nil?
          resp.each(&block)
        end
      end
    end
  end
end
