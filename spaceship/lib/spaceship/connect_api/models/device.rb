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

      def enabled?
        return status == Status::ENABLED
      end

      #
      # API
      #

      def self.all(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_devices(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      # @param client [ConnectAPI] ConnectAPI client.
      # @param platform [String] The platform of the device.
      # @param include_disabled [Bool] Whether to include disable devices. false by default.
      # @return (Device) Find a device based on the UDID of the device. nil if no device was found.
      def self.find_by_udid(device_udid, client: nil, platform: nil, include_disabled: false)
        self.all(client: client).find do |device|
          device.udid.casecmp(device_udid) == 0 && (include_disabled ? true : device.enabled?)
        end
      end

      # @param client [ConnectAPI] ConnectAPI client.
      # @param name [String] The name to be assigned to the device, if it needs to be created.
      # @param platform [String] The platform of the device.
      # @param include_disabled [Bool] Whether to include disable devices. false by default.
      # @return (Device) Find a device based on the UDID of the device. If no device was found,  nil if no device was found.
      def self.find_or_create(device_udid, client: nil, name: nil, platform: nil, include_disabled: false)
        existing = self.find_by_udid(device_udid, client: client, platform: platform)
        return existing if existing
        return self.create(client: client, name: name, platform: platform, udid: device_udid)
      end

      # @param client [ConnectAPI] ConnectAPI client.
      # @param name [String] The name to be assigned to the device.
      # @param platform [String] The platform of the device.
      # @param udid [String] The udid of the device being created.
      # @return (Device) Find a device based on the UDID of the device. nil if no device was found.
      def self.create(client: nil, name: nil, platform: nil, udid: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_device(name: name, platform: platform, udid: udid)
        return resp.to_models.first
      end
    end
  end
end
