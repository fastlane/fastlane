module Testflight
  class Base < Spaceship::Base
    def self.client
      @client ||= Testflight::Client.client_with_authorization_from(Spaceship::Tunes.client)
    end
  end
end