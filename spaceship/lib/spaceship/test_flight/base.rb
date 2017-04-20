module Spaceship::TestFlight
  class Base < Spaceship::Base
    def self.client
      @client ||= Client.client_with_authorization_from(Spaceship::Tunes.client)
    end

    def to_json
      raw_data.to_json
    end
  end
end
