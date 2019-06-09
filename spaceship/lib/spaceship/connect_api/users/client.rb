require_relative '../../client'
require_relative '../response'

module Spaceship
  # rubocop:disable Metrics/ClassLength
  module ConnectAPI
    module Users
      class Client < Spaceship::Client
        ##
        # Spaceship HTTP client for the App Store Connect API.
        #
        # This client is solely responsible for the making HTTP requests and
        # parsing their responses. Parameters should be either named parameters, or
        # for large request data bodies, pass in anything that can resond to
        # `to_json`.
        #
        # Each request method should validate the required parameters. A required parameter is one that would result in 400-range response if it is not supplied.
        # Each request method should make only one request. For more high-level logic, put code in the data models.

        def self.hostname
          'https://appstoreconnect.apple.com/iris/v1/'
        end

        #
        # Helpers
        #

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

        #
        # users
        #

        def get_users(filter: {}, includes: nil, limit: nil, sort: nil)
          # GET
          # https://appstoreconnect.apple.com/iris/v1/users
          params = build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          get("users", params)
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

        # used to assert all of the named parameters are supplied values
        #
        # @raises NameError if the values are nil
        def assert_required_params(method_name, binding)
          parameter_names = method(method_name).parameters.map { |_, v| v }
          parameter_names.each do |name|
            if local_variable_get(binding, name).nil?
              raise NameError, "`#{name}' is a required parameter"
            end
          end
        end

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
  end
  # rubocop:enable Metrics/ClassLength
end
