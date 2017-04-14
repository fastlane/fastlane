module Testflight
  class Build < Spaceship::Base
    def self.client
      @client ||= Testflight::Client.client_with_authorization_from(Spaceship::Tunes.client)
    end

    def self.find(provider_id, app_id, build_id)
      attrs = client.get_build(provider_id, app_id, build_id)
      require 'pry'; binding.pry
      self.new(attrs)
    end
  end
end
