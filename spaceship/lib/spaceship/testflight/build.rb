module Testflight
  class Build < Spaceship::Base
    def self.client
      @client ||= Spaceship::Tunes.client
    end
    
    def self.find(provider_id, app_id, build_id)
      self.new(client.get_build(provider_id, app_id, build_id))
    end
  end
end
