require_relative '../base'

module Spaceship
  module Tunes
    class TunesBase < Spaceship::Base
      class << self
        def client
          (
            @client or
            Spaceship::Tunes.client or
            raise "Please login using `Spaceship::Tunes.login('user', 'password')`"
          )
        end
      end
    end
  end
end
