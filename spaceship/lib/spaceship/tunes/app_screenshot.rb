module Spaceship
  module Tunes
    # Represents a screenshot hosted on iTunes Connect
    class AppScreenshot < Spaceship::Tunes::AppImage
      attr_accessor :device_type

      attr_accessor :language

      class << self
        # Create a new object based on a hash.
        def factory(attrs)
          self.new(attrs)
        end
      end
    end
  end
end
