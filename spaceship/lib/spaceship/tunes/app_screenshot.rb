require_relative 'app_image'

module Spaceship
  module Tunes
    # Represents a screenshot hosted on iTunes Connect
    class AppScreenshot < Spaceship::Tunes::AppImage
      attr_accessor :device_type

      attr_accessor :language
    end
  end
end
