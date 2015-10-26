module Spaceship
  module Tunes
    class DeviceType
      @types = ['iphone4', 'iphone35', 'iphone6', 'iphone6Plus', 'ipad', 'watch', 'appleTV']
      class << self
        attr_accessor :types

        def exists?(type)
          types.include? type
        end
      end
    end
  end
end
