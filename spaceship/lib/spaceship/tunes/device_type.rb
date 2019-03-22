module Spaceship
  module Tunes
    # identifiers of devices that App Store Connect accepts screenshots for
    class DeviceType
      @types = [
        # iPhone
        'iphone35',
        'iphone4',
        'iphone6', # 4.7-inch Display
        'iphone6Plus', # 5.5-inch Display
        'iphone58', # iPhone XS
        'iphone65', # iPhone XS Max

        # iPad
        'ipad', # 9.7-inch Display
        'ipad105',
        'ipadPro',
        'ipadPro11',
        'ipadPro129',

        # Apple Watch
        'watch', # series 3
        'watchSeries4',

        # Apple TV
        'appleTV',

        # Mac
        'desktop'
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
