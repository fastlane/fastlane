module Spaceship::TestFlight
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
      'https://itunesconnect.apple.com/testflight/v2/'
    end

    ##
    # @!group Build trains API
    ##

    # Returns an array of all available build trains (not the builds they include)
    def get_build_trains(app_id: nil, platform: "ios")
      assert_required_params(__method__, binding)

      response = request(:get, "providers/#{team_id}/apps/#{app_id}/platforms/#{platform}/trains")
      handle_response(response)
    end

    def get_builds_for_train(app_id: nil, platform: "ios", train_version: nil, retry_count: 0)
      assert_required_params(__method__, binding)
      with_retry(retry_count) do
        response = request(:get, "providers/#{team_id}/apps/#{app_id}/platforms/#{platform}/trains/#{train_version}/builds", nil, {}, true)
        handle_response(response)
      end
    end

    ##
    # @!group Builds API
    ##

    def get_build(app_id: nil, build_id: nil)
      assert_required_params(__method__, binding)

      response = request(:get, "providers/#{team_id}/apps/#{app_id}/builds/#{build_id}")
      handle_response(response)
    end

    def put_build(app_id: nil, build_id: nil, build: nil)
      assert_required_params(__method__, binding)

      response = request(:put) do |req|
        req.url "providers/#{team_id}/apps/#{app_id}/builds/#{build_id}"
        req.body = build.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_response(response)
    end

    def post_for_testflight_review(app_id: nil, build_id: nil, build: nil)
      assert_required_params(__method__, binding)

      response = request(:post) do |req|
        req.url "providers/#{team_id}/apps/#{app_id}/builds/#{build_id}/review"
        req.body = build.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_response(response)
    end

    def expire_build(app_id: nil, build_id: nil, build: nil)
      assert_required_params(__method__, binding)

      response = request(:post) do |req|
        req.url "providers/#{team_id}/apps/#{app_id}/builds/#{build_id}/expire"
        req.body = build.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_response(response)
    end

    ##
    # @!group Groups API
    ##

    def get_groups(app_id: nil)
      assert_required_params(__method__, binding)

      response = request(:get, "/testflight/v2/providers/#{team_id}/apps/#{app_id}/groups")
      handle_response(response)
    end

    def add_group_to_build(app_id: nil, group_id: nil, build_id: nil)
      assert_required_params(__method__, binding)

      body = {
        'groupId' => group_id,
        'buildId' => build_id
      }
      response = request(:put) do |req|
        req.url "providers/#{team_id}/apps/#{app_id}/groups/#{group_id}/builds/#{build_id}"
        req.body = body.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_response(response)
    end

    ##
    # @!group Testers API
    ##

    def testers_for_app(app_id: nil)
      assert_required_params(__method__, binding)
      page_size = 40 # that's enforced by the iTC servers
      offset = nil
      resulting_array = []

      loop do
        url = "providers/#{team_id}/apps/#{app_id}/testers?limit=#{page_size}&sort=email&order=asc"
        url += "&offset=#{offset}" if offset
        response = request(:get, url)
        result = Array(handle_response(response))
        resulting_array += result
        break if result.count == 0
        offset = "#{result.last['email']}%2C#{result.last['id']}"
      end
      return resulting_array
    end

    def delete_tester_from_app(app_id: nil, tester_id: nil)
      assert_required_params(__method__, binding)
      url = "providers/#{team_id}/apps/#{app_id}/testers/#{tester_id}"
      response = request(:delete, url)
      handle_response(response)
    end

    def search_for_tester_in_app(app_id: nil, text: nil)
      assert_required_params(__method__, binding)
      text = CGI.escape(text)
      url = "providers/#{team_id}/apps/#{app_id}/testers?order=asc&search=#{text}&sort=status"
      response = request(:get, url)
      handle_response(response)
    end

    def resend_invite_to_external_tester(app_id: nil, tester_id: nil)
      assert_required_params(__method__, binding)
      url = "/testflight/v1/invites/#{app_id}/resend?testerId=#{tester_id}"
      response = request(:post, url)
      handle_response(response)
    end

    def create_app_level_tester(app_id: nil, first_name: nil, last_name: nil, email: nil)
      assert_required_params(__method__, binding)
      url = "providers/#{team_id}/apps/#{app_id}/testers"
      response = request(:post) do |req|
        req.url url
        req.body = {
          "email" => email,
          "firstName" => first_name,
          "lastName" => last_name
        }.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_response(response)
    end

    def put_tester_to_group(app_id: nil, tester_id: nil, group_id: nil)
      assert_required_params(__method__, binding)

      # Then we can add the tester to the group that allows the app to test
      # This is easy enough, we already have all this data. We don't need any response from the previous request
      url = "providers/#{team_id}/apps/#{app_id}/groups/#{group_id}/testers/#{tester_id}"
      response = request(:put) do |req|
        req.url url
        req.body = {
          "groupId" => group_id,
          "testerId" => tester_id
        }.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_response(response)
    end

    def delete_tester_from_group(group_id: nil, tester_id: nil, app_id: nil)
      assert_required_params(__method__, binding)

      url = "providers/#{team_id}/apps/#{app_id}/groups/#{group_id}/testers/#{tester_id}"
      response = request(:delete) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
      end
      handle_response(response)
    end

    ##
    # @!group AppTestInfo
    ##

    def get_app_test_info(app_id: nil)
      assert_required_params(__method__, binding)

      response = request(:get, "providers/#{team_id}/apps/#{app_id}/testInfo")
      handle_response(response)
    end

    def put_app_test_info(app_id: nil, app_test_info: nil)
      assert_required_params(__method__, binding)

      response = request(:put) do |req|
        req.url "providers/#{team_id}/apps/#{app_id}/testInfo"
        req.body = app_test_info.to_json
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
  end
end
