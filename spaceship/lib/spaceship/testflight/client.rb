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
