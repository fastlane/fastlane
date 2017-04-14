module Testflight
  class Client < Spaceship::Client
    def self.hostname
      'https://itunesconnect.apple.com/testflight/v2/'
    end

    def get_build(provider_id, app_id, build_id)
      r = request(:get, "providers/#{provider_id}/apps/#{app_id}/builds/#{build_id}")
      r.body['data']
    end
  end
end
