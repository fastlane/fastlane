module Spaceship
  module Tunes
    class DeviceType
      @types = ['iphone4', 'iphone35', 'iphone6', 'iphone6Plus', 'iphone58', 'iphone65', 'ipad', 'ipadPro', 'ipad105', 'watch', 'watchSeries4', 'appleTV', 'desktop']
      class << self
        attr_accessor :types

        def exists?(type)
          types.include?(type)
        end
      end
    end
  end
end
