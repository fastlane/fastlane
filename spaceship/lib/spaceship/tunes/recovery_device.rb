require_relative 'tunes_base'

module Spaceship
  module Tunes
    class RecoveryDevice < TunesBase
      # @return (String) ID provided by Apple
      # @example
      #   "1801231651"
      attr_accessor :device_id

      # @return (String) The name of the device
      # @example
      #   "Felix Krause's iPhone 6"
      attr_accessor :name

      # @return (Bool) This device looks suspicious [add emoji here]
      #   this will probably always be true, otherwise the device
      #   doesn't show up
      # @example
      #   true
      attr_accessor :trusted

      # @return (Bool)
      # @example
      #   true
      attr_accessor :status

      # @return (String) Remote URL to an image representing this device
      #   This shows the attention to detail by Apple <3
      # @example
      #   "https://appleid.cdn-apple.com/static/deviceImages-5.0/iPhone/iPhone8,1-e4e7e8-dadcdb/online-sourcelist__3x.png"
      # @example
      #   "https://appleid.cdn-apple.com/appleauth/static/bin/cb2613252489/images/sms@3x.png"
      attr_accessor :device_image

      # @return (String)
      # @example
      #   "iPad Air"
      # @example
      #   nil # e.g. when it's a phone number
      attr_accessor :model_name

      # @return (String)
      # @example
      #   "79"
      attr_accessor :last_two_digits

      # @return (Number)
      # @example
      #   1446488271926
      attr_accessor :update_date

      attr_mapping(
        'id' => :device_id,
        'name' => :name,
        'trusted' => :trusted,
        'status' => :status,
        'imageLocation3x' => :device_image,
        'modelName' => :model_name,
        'lastTwoDigits' => :last_two_digits,
        'updateDate' => :update_date
      )
    end
  end
end
