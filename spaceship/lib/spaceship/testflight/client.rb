module Testflight
  class Client < Spaceship::Client
    def self.hostname
      'https://itunesconnect.apple.com/testflight/v2/'
    end

    def get_build(provider_id, app_id, build_id)
      r = request(:get, "providers/#{provider_id}/apps/#{app_id}/builds/#{build_id}")
      r.body['data']
    end

    def put_build(provider_id, app_id, build_id, build_data)
      puts 'HERE'
      begin
        response = request(:put) do |req|
          req.url "providers/#{provider_id}/apps/#{app_id}/builds/#{build_id}"
          req.body = build_data.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        body = response.body['data']
        require 'pry'; binding.pry
        puts 'success'
      rescue => e
        require 'pry'; binding.pry
        puts 'error'
      end
      0
    end

  end
end
