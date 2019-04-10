module Spaceship
  module Tunes
    # identifiers of device types that App Store Connect accepts screenshots for
    class DeviceType
      @types = [
        # iPhone
        'iphone35',     #  3.5-inch Display
        'iphone4',      #    4-inch Display
        'iphone6',      #  4.7-inch Display
        'iphone6Plus',  #  5.5-inch Display
        'iphone58',     #  5.8-inch Display, iPhone XS
        'iphone65',     #  6.5-inch Display, iPhone XS Max

        # iPad
        'ipad',         #  9.7-inch Display
        'ipad105',      # 10.5-inch Display
        'ipadPro',      # 12.9-inch Display, iPad Pro (2nd Generation)
        'ipadPro11',    #   11-inch Display
        'ipadPro129',   # 12.9-inch Display, iPad Pro (3rd Generation)

        # Apple Watch
        'watch',
        'watchSeries4', # Series 4

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
