require_relative '../client'

module Spaceship
  module ConnectAPI
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

      def build_url(path: nil, filter: nil, includes: nil, limit: nil, sort: nil)
        params = {}

        if filter
          filter.keys.each do |key|
            params["filter[#{key}]"] = filter[key]
          end
        end

        params["include"] = includes if includes
        params["limit"] = limit if limit
        params["sort"] = sort if sort

        query_params = params.map do |k, v|
          "#{k}=#{v}"
        end.join("&")

        url = "#{path}?#{query_params}"
        return url
      end

      def get_beta_app_review_detail(filter: {}, includes: nil, limit: nil, sort: nil)
        # assert_required_params(__method__, binding)

        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaAppReviewDetails?filter[app]=<app_id>
        path = "betaAppReviewDetails"
        url = build_url(path: path, filter: filter, includes: includes, limit: limit, sort: sort)

        response = request(:get, url)
        handle_response(response)
      end

      def patch_beta_app_review_detail(app_id: nil, feedbackEmail: nil, attributes: {})
        # assert_required_params(__method__, binding)

        # PATCH
        # https://appstoreconnect.apple.com/iris/v1/apps/<app_id>/betaAppReviewDetails
        path = "betaAppReviewDetails/#{app_id}"
        url = build_url(path: path, filter: nil, includes: nil, limit: nil, sort: nil)

        body = {
          data: {
            attributes: attributes,
            id: app_id,
            type: "betaAppReviewDetails"
          }
        }

        response = request(:patch) do |req|
          req.url(url)
          req.body = body.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_response(response)
      end

      def get_beta_app_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
        # assert_required_params(__method__, binding)

        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaAppLocalizations?filter[app]=<app_id>
        path = "betaAppLocalizations"
        url = build_url(path: path, filter: filter, includes: includes, limit: limit, sort: sort)

        response = request(:get, url)
        handle_response(response)
      end

      def get_beta_build_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
        # assert_required_params(__method__, binding)

        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaBuildLocalizations?filter[build]=<build_id>
        path = "betaBuildLocalizations"
        url = build_url(path: path, filter: filter, includes: includes, limit: limit, sort: sort)

        response = request(:get, url)
        handle_response(response)
      end

      def post_beta_app_localizations(app_id: nil, attributes: {})
        # assert_required_params(__method__, binding)

        # POST
        # https://appstoreconnect.apple.com/iris/v1/betaAppLocalizations
        path = "betaAppLocalizations"
        url = build_url(path: path, filter: nil, includes: nil, limit: nil, sort: nil)

        body = {
          data: {
            attributes: attributes,
            type: "betaAppLocalizations",
            relationships: {
              app: {
                data: {
                  type: "apps",
                  id: app_id
                }
              }
            }
          }
        }

        response = request(:post) do |req|
          req.url(url)
          req.body = body.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_response(response)
      end

      def patch_beta_app_localizations(localization_id: nil, attributes: {})
        # assert_required_params(__method__, binding)

        # PATCH
        # https://appstoreconnect.apple.com/iris/v1/apps/<app_id>/betaAppLocalizations/<localization_id>
        path = "betaAppLocalizations/#{localization_id}"
        url = build_url(path: path, filter: nil, includes: nil, limit: nil, sort: nil)

        body = {
          data: {
            attributes: attributes,
            id: localization_id,
            type: "betaAppLocalizations"
          }
        }

        response = request(:patch) do |req|
          req.url(url)
          req.body = body.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_response(response)
      end

      def post_beta_build_localizations(build_id: nil, attributes: {})
        # assert_required_params(__method__, binding)

        # POST
        # https://appstoreconnect.apple.com/iris/v1/betaBuildLocalizations
        path = "betaBuildLocalizations"
        url = build_url(path: path, filter: nil, includes: nil, limit: nil, sort: nil)

        body = {
          data: {
            attributes: attributes,
            type: "betaBuildLocalizations",
            relationships: {
              build: {
                data: {
                  type: "builds",
                  id: build_id
                }
              }
            }
          }
        }

        response = request(:post) do |req|
          req.url(url)
          req.body = body.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_response(response)
      end

      def patch_beta_build_localizations(localization_id: nil, feedbackEmail: nil, attributes: {})
        # assert_required_params(__method__, binding)

        # PATCH
        # https://appstoreconnect.apple.com/iris/v1/apps/<app_id>/betaBuildLocalizations
        path = "betaBuildLocalizations/#{localization_id}"
        url = build_url(path: path, filter: nil, includes: nil, limit: nil, sort: nil)

        body = {
          data: {
            attributes: attributes,
            id: localization_id,
            type: "betaBuildLocalizations"
          }
        }

        response = request(:patch) do |req|
          req.url(url)
          req.body = body.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_response(response)
      end

      def get_builds(filter: {}, includes: "buildBetaDetail,betaBuildMetrics", limit: 10, sort: "uploadedDate")
        assert_required_params(__method__, binding)

        # GET
        # https://appstoreconnect.apple.com/iris/v1/builds
        url = build_url(path: "builds", filter: filter, includes: includes, limit: limit, sort: sort)

        response = request(:get, url)
        handle_response(response)
      end

      def get_prerelease_versions(filter: {}, includes: "buildBetaDetail,betaBuildMetrics", limit: 10, sort: "uploadedDate")
        assert_required_params(__method__, binding)

        # GET
        # https://appstoreconnect.apple.com/iris/v1/builds
        url = build_url(path: "builds", filter: filter, includes: includes, limit: limit, sort: sort)

        response = request(:get, url)
        handle_response(response)
      end

      def post_for_testflight_review(build_id: nil)
        assert_required_params(__method__, binding)

        # POST
        # https://appstoreconnect.apple.com/iris/v1/betaAppReviewSubmissions
        #
        # {"data":{"type":"betaAppReviewSubmissions","relationships":{"build":{"data":{"type":"builds","id":"6f90f04a-3b48-4d4a-9bbd-9475c294a579"}}}}}

        body = {
          data: {
            type: "betaAppReviewSubmissions",
            relationships: {
              build: {
                data: {
                  type: "builds",
                  id: build_id
                }
              }
            }
          }
        }

        response = request(:post) do |req|
          req.url("betaAppReviewSubmissions")
          req.body = body.to_json
          req.headers['Content-Type'] = 'application/json'
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

        return response.body['data'] if response.body['data']

        return response.body
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
