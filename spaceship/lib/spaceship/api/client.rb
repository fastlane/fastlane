require_relative '../client'

module Spaceship
  module API
    class Client < Spaceship::Client
      ##
      # Spaceship HTTP client for the testflight API.
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

      def get_apps
        assert_required_params(__method__, binding)

        response = request(:get, "apps")
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

        raise UnexpectedResponse, "Temporary App Store Connect error: #{response.body}" if response.body['statusCode'] == 'ERROR'

        return response.body['data'] if response.body['data']

        return response.body
      end

      private

      # used to assert all of the named parameters are supplied values
      #
      # @raises NameError if the values are nil
      def assert_required_params(method_name, binding)
        parameter_names = method(method_name).parameters.map { |k, v| v }
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
