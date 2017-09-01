require "spaceship/base"
require "spaceship/tunes/tunes_base"
require "spaceship/tunes/tester"

module Spaceship
  module Tunes
    # monkey patched
    # move this to spaceship
    class Tester < TunesBase
      def pretty_install_date
        return nil unless latest_install_date
        Time.at((latest_install_date / 1000)).strftime("%m/%d/%y %H:%M")
      end
    end
  end
end
