module Spaceship
  class TunesBase < Spaceship::Base
    class << self
      def client
        @client || Spaceship::Tunes.client
      end
    end
  end
end