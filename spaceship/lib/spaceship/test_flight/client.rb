module TestFlight
  class Client < Spaceship::Client
    def self.hostname
      'https://itunesconnect.apple.com/testflight/v2/'
    end

    # Returns an array of all available build trains (not the builds they include)
    def all_build_trains(provider_id: nil, app_id: nil, platform: nil)
      platform ||= "ios"
      response = request(:get, "providers/#{provider_id}/apps/#{app_id}/platforms/#{platform}/trains")
      response.body['data']
    end

    # Iterates over all build trains and lists all available builds for each train
    def all_builds(provider_id: nil, app_id: nil, platform: nil)
      platform ||= "ios"
      build_trains = all_build_trains(provider_id: provider_id, app_id: app_id, platform: platform)
      result = {}
      build_trains.each do |current_train_number|
        response = request(:get, "providers/#{provider_id}/apps/#{app_id}/platforms/#{platform}/trains/#{current_train_number}/builds")
        result[current_train_number] = response.body['data']
      end
      return result
    end

    def add_tester_to_group!(provider_id: nil, group: nil, tester: nil, app_id: nil)
      # First we need to add the tester to the app
      # It's ok if the tester already exists, we just have to do this... don't ask
      # This will enable testing for the tester for a given app, as just creating the tester on an account-level
      # is not enough to add the tester to a group. If this isn't done the next request would fail.
      # This is a bug we reported to the iTunes Connect team, as it also happens on the iTunes Connect UI on 18. April 2017
      url = "providers/#{provider_id}/apps/#{app_id}/testers"
      request(:post) do |req|
        req.url url
        req.body = {
          "email" => tester.email,
          "firstName" => tester.last_name,
          "lastName" => tester.first_name,
        }.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      # TODO: add error handling here: https://github.com/fastlane/fastlane/pull/8871#issuecomment-294669432

      # Then we can add the tester to the group that allows the app to test
      # This is easy enough, we already have all this data. We don't need any response from the previous request
      url = "providers/#{provider_id}/apps/#{app_id}/groups/#{group.id}/testers/#{tester.tester_id}"
      request(:put) do |req|
        req.url url
        req.body = {
          "groupId" => group.id,
          "testerId" => tester.tester_id
        }.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      # TODO: add error handling here: https://github.com/fastlane/fastlane/pull/8871#issuecomment-294669432
    end

    def remove_tester_from_group!(provider_id: nil, group: nil, tester: nil, app_id: nil)
      url = "providers/#{provider_id}/apps/#{app_id}/groups/#{group.id}/testers/#{tester.tester_id}"
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
      response = request(:post) do |req|
        req.url "providers/#{provider_id}/apps/#{app_id}/builds/#{build_id}/review"
        req.body = build.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      response.body
    end

    def all_groups(provider_id, app_id)
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

  # def groups(app_id)
  #   return @cached_groups if @cached_groups
  #   r = request(:get, "/testflight/v2/providers/#{team_id}/apps/#{app_id}/groups")
  #   @cached_groups = parse_response(r, 'data')
  # end
end
