module TestFlight
  class Client < Spaceship::Client
    def self.hostname
      'https://itunesconnect.apple.com/testflight/v2/'
    end

    # Returns an array of all available build trains (not the builds they include)
    def get_build_trains(provider_id: nil, app_id: nil, platform: nil)
      platform ||= "ios"
      response = request(:get, "providers/#{provider_id}/apps/#{app_id}/platforms/#{platform}/trains")
      response.body['data']
      # TODO: add error handling here: https://github.com/fastlane/fastlane/pull/8871#issuecomment-294669432
    end

    def get_builds_for_train(provider_id: nil, app_id: nil, platform: nil, train_version: nil)
      platform ||= "ios"

      response = request(:get, "providers/#{provider_id}/apps/#{app_id}/platforms/#{platform}/trains/#{train_version}/builds")
      response.body['data']
      # TODO: add error handling here: https://github.com/fastlane/fastlane/pull/8871#issuecomment-294669432
    end

    def post_tester(provider_id: nil, app_id: nil, tester: nil)
      url = "providers/#{provider_id}/apps/#{app_id}/testers"
      request(:post) do |req|
        req.url url
        req.body = {
          "email" => tester.email,
          "firstName" => tester.last_name,
          "lastName" => tester.first_name
        }.to_json
        req.headers['Content-Type'] = 'application/json'
      end
    end

    def put_test_to_group(provider_id: nil, app_id: nil, tester_id: nil, group_id: nil)
      url = "providers/#{provider_id}/apps/#{app_id}/groups/#{group_id}/testers/#{tester_id}"
      request(:put) do |req|
        req.url url
        req.body = {
          "groupId" => group_id,
          "testerId" => tester_id
        }.to_json
        req.headers['Content-Type'] = 'application/json'
      end
    end

    #def remove_tester_from_group!(provider_id: nil, group: nil, tester: nil, app_id: nil)
    def delete_tester_from_group(provider_id: nil, group_id: nil, tester_id: nil, app_id: nil)
      url = "providers/#{provider_id}/apps/#{app_id}/groups/#{group_id}/testers/#{tester_id}"
      response = request(:delete) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
      end
      # TODO: add error handling here: https://github.com/fastlane/fastlane/pull/8871#issuecomment-294669432
    end

    def get_build(provider_id, app_id, build_id)
      response = request(:get, "providers/#{provider_id}/apps/#{app_id}/builds/#{build_id}")
      response.body['data']
    end

    def put_build(provider_id, app_id, build_id, build)
      response = request(:put) do |req|
        req.url "providers/#{provider_id}/apps/#{app_id}/builds/#{build_id}"
        req.body = build.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      response.body['data']
    end

    def post_for_review(provider_id, app_id, build_id, build)
      begin
        response = request(:post) do |req|
          req.url "providers/#{provider_id}/apps/#{app_id}/builds/#{build_id}/review"
          req.body = build.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        response.body
        require 'pry'; binding.pry
        puts ''
      rescue => e
        require 'pry'; binding.pry
        puts ''
      end
    end

    def get_groups(provider_id, app_id)
      response = request(:get, "/testflight/v2/providers/#{provider_id}/apps/#{app_id}/groups")
      response.body['data']
    end

    def add_group_to_build(provider_id, app_id, group_id, build_id)
      # TODO: if no group specified default to isDefaultExternalGroup
      body = {
        'groupId' => group_id,
        'buildId' => build_id
      }
      response = request(:put) do |req|
        req.url "providers/#{provider_id}/apps/#{app_id}/groups/#{group_id}/builds/#{build_id}"
        req.body = body.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      response.body
    end
  end
end
