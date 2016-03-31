module Spaceship
  module Tunes
    # Represents an export compliance file hosted on ITC
    class AppCcatFile < TunesBase
      attr_accessor :url

      attr_accessor :name

      attr_accessor :asset_token

      attr_accessor :timestamp

      attr_accessor :file_type

      attr_mapping(
        'url' => :url,
        'name' => :name,
        'assetToken' => :asset_token,
        'timestamp' => :timestamp,
        'fileType' => :file_type
      )

      class << self
        def factory(attrs)
          self.new(attrs)
        end
      end
    end
  end
end
