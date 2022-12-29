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

        # As of 2022-11-12, this is not officially supported by App Store Connect API
        APPLE_SILICON_MAC = "APPLE_SILICON_MAC"
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
      def self.find_by_udid(device_udid, client: nil, include_disabled: false)
        self.all(client: client).find do |device|
          device.udid.casecmp(device_udid) == 0 && (include_disabled ? true : device.enabled?)
        end
      end

      # @param client [ConnectAPI] ConnectAPI client.
      # @param name [String] The name to be assigned to the device, if it needs to be created.
      # @param platform [String] The platform of the device.
      # @return (Device) Find a device based on the UDID of the device. If no device was found,  nil if no device was found.
      def self.find_or_create(device_udid, client: nil, name: nil, platform: nil)
        existing = self.find_by_udid(device_udid, client: client)
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

      # @param device_udid [String] Device Provisioning UDID that needs to be modified.
      # @param client [ConnectAPI] ConnectAPI client.
      # @param enabled [Boolean] New enabled value. true - if device must be enabled, `false` - to disable device. nil if no status change needed.
      # @param new_name [String] A new name for the device. nil if no name change needed.
      # @return (Device) Modified device based on the UDID of the device. nil if no device was found.
      def self.modify(device_udid, client: nil, enabled: nil, new_name: nil)
        client ||= Spaceship::ConnectAPI
        existing = self.find_by_udid(device_udid, client: client, include_disabled: true)
        return nil if existing.nil?

        enabled = existing.enabled? if enabled.nil?
        new_name ||= existing.name
        return existing if existing.name == new_name && existing.enabled? == enabled
        new_status = enabled ? Status::ENABLED : Status::DISABLED

        resp = client.patch_device(id: existing.id, new_name: new_name, status: new_status)
        return resp.to_models.first
      end

      # @param device_udid [String] Device Provisioning UDID that needs to be enabled.
      # @param client [ConnectAPI] ConnectAPI client.
      # @return (Device) Modified device based on the UDID of the device. nil if no device was found.
      def self.enable(device_udid, client: nil)
        self.modify(device_udid, client: client, enabled: true)
      end

      # @param device_udid [String] Device Provisioning UDID that needs to be disabled.
      # @param client [ConnectAPI] ConnectAPI client.
      # @return (Device) Modified device based on the UDID of the device. nil if no device was found.
      def self.disable(device_udid, client: nil)
        self.modify(device_udid, client: client, enabled: false)
      end

      # @param device_udid [String] Device Provisioning UDID that needs to be renamed.
      # @param new_name [String] A new name for the device.
      # @param client [ConnectAPI] ConnectAPI client.
      # @return (Device) Modified device based on the UDID of the device. nil if no device was found.
      def self.rename(device_udid, new_name, client: nil)
        self.modify(device_udid, client: client, new_name: new_name)
      end
    end
  end
end
