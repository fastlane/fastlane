module Spaceship::TestFlight
  class Client < Spaceship::Client
    def self.hostname
      'https://itunesconnect.apple.com/testflight/v2/'
    end

    # Returns an array of all available build trains (not the builds they include)
    def get_build_trains(app_id: nil, platform: nil)
      assert_required_params(__method__, binding)
      platform ||= "ios"
      response = request(:get, "providers/#{team_id}/apps/#{app_id}/platforms/#{platform}/trains")
      handle_response(response)
    end

    def get_builds_for_train(app_id: nil, platform: nil, train_version: nil)
      assert_required_params(__method__, binding)
      platform ||= "ios"

      response = request(:get, "providers/#{team_id}/apps/#{app_id}/platforms/#{platform}/trains/#{train_version}/builds")
      handle_response(response)
    end

    def post_tester(app_id: nil, tester: nil)
      assert_required_params(__method__, binding)
      url = "providers/#{team_id}/apps/#{app_id}/testers"
      response = request(:post) do |req|
        req.url url
        req.body = {
          "email" => tester.email,
          "firstName" => tester.first_name,
          "lastName" => tester.last_name
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

    def get_groups(app_id: nil)
      assert_required_params(__method__, binding)
      response = request(:get, "/testflight/v2/providers/#{team_id}/apps/#{app_id}/groups")
      handle_response(response)
    end

    def add_group_to_build(app_id: nil, group_id: nil, build_id: nil)
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

    def handle_response(response)
      if (200..300).cover?(response.status) && response.body.empty?
        return
      end

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
      parameter_names = Hash[method(method_name).parameters].values
      parameter_names.each do |name|
        if binding.local_variable_get(name).nil?
          raise NameError, "`#{name}' is a required parameter"
        end
      end
    end
  end
end
