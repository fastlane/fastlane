require_relative 'tunes_base'

module Spaceship
  module Tunes
    # Represents a geo json
    class TransitAppFile < TunesBase
      attr_accessor :asset_token

      attr_accessor :name

      attr_accessor :time_stamp

      attr_accessor :url

      attr_mapping(
        'assetToken' => :asset_token,
        'timeStemp' => :time_stamp,
        'url' => :url,
        'name' => :name
      )
    end
  end
end
