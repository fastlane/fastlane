module Spaceship
  module Tunes
    # identifiers of devices that App Store Connect accepts screenshots for
    class DeviceType
      @types = %w[
        iphone35
        iphone4
        iphone6
        iphone6Plus
        iphone58
        iphone65
        ipad
        ipad105
        ipadPro
        ipadPro11
        ipadPro129
        watch
        watchSeries4
        appleTV
        desktop
      ]
      class << self
        attr_accessor :types

        def exists?(type)
          types.include?(type)
        end
      end
    end
  end
end
