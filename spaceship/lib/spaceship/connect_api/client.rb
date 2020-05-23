require_relative '../client'
require_relative './response'

module Spaceship
  class ConnectAPI
    class Client < Spaceship::Client
      attr_accessor :token

      #####################################################
      # @!group Client Init
      #####################################################

      # Instantiates a client with cookie session or a JWT token.
      def initialize(cookie: nil, current_team_id: nil, token: nil)
        if token.nil?
          super(cookie: cookie, current_team_id: current_team_id)
        else
          options = {
            request: {
              timeout:       (ENV["SPACESHIP_TIMEOUT"] || 300).to_i,
              open_timeout:  (ENV["SPACESHIP_TIMEOUT"] || 300).to_i
            }
          }
          @token = token
          @current_team_id = current_team_id

          hostname = "https://api.appstoreconnect.apple.com/v1/"

          @client = Faraday.new(hostname, options) do |c|
            c.response(:json, content_type: /\bjson$/)
            c.response(:xml, content_type: /\bxml$/)
            c.response(:plist, content_type: /\bplist$/)
            c.use(FaradayMiddleware::RelsMiddleware)
            c.adapter(Faraday.default_adapter)
            c.headers["Authorization"] = "Bearer #{token.text}"

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

      def self.hostname
        return nil
      end

      #
      # Helpers
      #

      def web_session?
        return @token.nil?
      end

      def build_params(filter: nil, includes: nil, limit: nil, sort: nil, cursor: nil)
        params = {}

        filter = filter.delete_if { |k, v| v.nil? } if filter

        params[:filter] = filter if filter && !filter.empty?
        params[:include] = includes if includes
        params[:limit] = limit if limit
        params[:sort] = sort if sort
        params[:cursor] = cursor if cursor

        return params
      end

      def get(url_or_path, params = nil)
        response = request(:get) do |req|
          req.url(url_or_path)
          req.options.params_encoder = Faraday::NestedParamsEncoder
          req.params = params if params
          req.headers['Content-Type'] = 'application/json'
        end
        handle_response(response)
      end

      def post(url_or_path, body)
        response = request(:post) do |req|
          req.url(url_or_path)
          req.body = body.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_response(response)
      end

      def patch(url_or_path, body)
        response = request(:patch) do |req|
          req.url(url_or_path)
          req.body = body.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_response(response)
      end

      def delete(url_or_path, params = nil, body = nil)
        response = request(:delete) do |req|
          req.url(url_or_path)
          req.options.params_encoder = Faraday::NestedParamsEncoder if params
          req.params = params if params
          req.body = body.to_json if body
          req.headers['Content-Type'] = 'application/json' if body
        end
        handle_response(response)
      end

      protected

      def handle_response(response)
        if (200...300).cover?(response.status) && (response.body.nil? || response.body.empty?)
          return
        end

        raise InternalServerError, "Server error got #{response.status}" if (500...600).cover?(response.status)

        unless response.body.kind_of?(Hash)
          raise UnexpectedResponse, response.body
        end

        raise UnexpectedResponse, response.body['error'] if response.body['error']

        raise UnexpectedResponse, handle_errors(response) if response.body['errors']

        raise UnexpectedResponse, "Temporary App Store Connect error: #{response.body}" if response.body['statusCode'] == 'ERROR'

        return Spaceship::ConnectAPI::Response.new(body: response.body, status: response.status, client: self)
      end

      def handle_errors(response)
        # Example error format
        # {
        #   "errors" : [ {
        #     "id" : "ce8c391e-f858-411b-a14b-5aa26e0915f2",
        #     "status" : "400",
        #     "code" : "PARAMETER_ERROR.INVALID",
        #     "title" : "A parameter has an invalid value",
        #     "detail" : "'uploadedDate3' is not a valid field name",
        #     "source" : {
        #       "parameter" : "sort"
        #     }
        #   } ]
        # }

        return response.body['errors'].map do |error|
          "#{error['title']} - #{error['detail']}"
        end.join(" ")
      end

      private

      def local_variable_get(binding, name)
        if binding.respond_to?(:local_variable_get)
          binding.local_variable_get(name)
        else
          binding.eval(name.to_s)
        end
      end

      def provider_id
        return team_id if self.provider.nil?
        self.provider.provider_id
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
