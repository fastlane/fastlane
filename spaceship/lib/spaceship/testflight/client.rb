module Testflight
  class Client < Spaceship::Client
    def self.hostname
      'https://itunesconnect.apple.com/testflight/v2/'
    end

    def get_build(provider_id, app_id, build_id)
      r = request(:get, "providers/#{provider_id}/apps/#{app_id}/builds/#{build_id}")
      r.body['data']
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
      response.body['data']
      require 'pry'; binding.pry
      puts ''
    end
  end

  # def groups(app_id)
#   return @cached_groups if @cached_groups
#   r = request(:get, "/testflight/v2/providers/#{team_id}/apps/#{app_id}/groups")
#   @cached_groups = parse_response(r, 'data')
# end
end
