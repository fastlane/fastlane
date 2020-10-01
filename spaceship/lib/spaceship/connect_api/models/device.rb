require_relative '../model'
module Spaceship
  class ConnectAPI
    class Device
      include Spaceship::ConnectAPI::Model

      attr_accessor :device_class
      attr_accessor :model
      attr_accessor :name
      attr_accessor :platform
      attr_accessor :status
      attr_accessor :udid
      attr_accessor :added_date

      attr_mapping({
        "deviceClass" => "device_class",
        "model" => "model",
        "name" => "name",
        "platform" => "platform",
        "status" => "status",
        "udid" => "udid",
        "addedDate" => "added_date"
      })

      module DeviceClass
        APPLE_WATCH = "APPLE_WATCH"
        IPAD = "IPAD"
        IPHONE = "IPHONE"
        IPOD = "IPOD"
        APPLE_TV = "APPLE_TV"
        MAC = "MAC"
      end

      module Status
        ENABLED = "ENABLED"
        DISABLED = "DISABLED"
      end

      def self.type
        return "devices"
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_devices(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end
    end
  end
end
