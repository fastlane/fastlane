require_relative 'portal_base'

module Spaceship
  module Portal
    # Represents a device from the Apple Developer Portal
    class Device < PortalBase
      # @return (String) The ID given from the developer portal. You'll probably not need it.
      # @example
      #   "XJXGVS46MW"
      attr_accessor :id

      # @return (String) The name of the device, must be 50 characters or less.
      # @example
      #   "Felix Krause's iPhone 6"
      attr_accessor :name

      # @return (String) The UDID of the device
      # @example
      #   "4c24a7ee5caaa4847f49aaab2d87483053f53b65"
      attr_accessor :udid

      # @return (String) The platform of the device. This is probably always "ios"
      # @example
      #   "ios"
      attr_accessor :platform

      # @return (String) Status of the device. "c" for enabled devices, "r" for disabled devices.
      # @example
      #   "c"
      attr_accessor :status

      # @return (String) Model (can be nil)
      # @example
      #   'iPhone 6', 'iPhone 4 GSM'
      attr_accessor :model

      # @return (String) Device type
      # @example
      #   'watch'  - Apple Watch
      #   'ipad'   - iPad
      #   'iphone' - iPhone
      #   'ipod'   - iPod
      #   'tvOS'   - Apple TV
      attr_accessor :device_type

      attr_mapping({
        'deviceId' => :id,
        'name' => :name,
        'deviceNumber' => :udid,
        'devicePlatform' => :platform,
        'status' => :status,
        'deviceClass' => :device_type,
        'model' => :model
      })

      class << self
        # @param mac [Bool] Fetches Mac devices if true
        # @param include_disabled [Bool] Whether to include disable devices. false by default.
        # @return (Array) Returns all devices registered for this account
        def all(mac: false, include_disabled: false)
          client.devices(mac: mac, include_disabled: include_disabled).map { |device| self.factory(device) }
        end

        # @return (Array) Returns all Apple TVs registered for this account
        def all_apple_tvs
          client.devices_by_class('tvOS').map { |device| self.factory(device) }
        end

        # @return (Array) Returns all Watches registered for this account
        def all_watches
          client.devices_by_class('watch').map { |device| self.factory(device) }
        end

        # @return (Array) Returns all iPads registered for this account
        def all_ipads
          client.devices_by_class('ipad').map { |device| self.factory(device) }
        end

        # @return (Array) Returns all iPhones registered for this account
        def all_iphones
          client.devices_by_class('iphone').map { |device| self.factory(device) }
        end

        # @return (Array) Returns all iPods registered for this account
        def all_ipod_touches
          client.devices_by_class('ipod').map { |device| self.factory(device) }
        end

        # @return (Array) Returns all Macs registered for this account
        def all_macs
          all(mac: true)
        end

        # @return (Array) Returns all devices that can be used for iOS profiles (all devices except TVs)
        def all_ios_profile_devices
          all.reject { |device| device.device_type == "tvOS" }
        end

        # @return (Array) Returns all devices matching the provided profile_type
        def all_for_profile_type(profile_type)
          if profile_type.include?("tvOS")
            Spaceship::Portal::Device.all_apple_tvs
          elsif profile_type.include?("Mac")
            Spaceship::Portal::Device.all_macs
          else
            Spaceship::Portal::Device.all_ios_profile_devices
          end
        end

        # @param mac [Bool] Searches for Macs if true
        # @param include_disabled [Bool] Whether to include disable devices. false by default.
        # @return (Device) Find a device based on the ID of the device. *Attention*:
        #  This is *not* the UDID. nil if no device was found.
        def find(device_id, mac: false, include_disabled: false)
          all(mac: mac, include_disabled: include_disabled).find do |device|
            device.id == device_id
          end
        end

        # @param mac [Bool] Searches for Macs if true
        # @param include_disabled [Bool] Whether to include disable devices. false by default.
        # @return (Device) Find a device based on the UDID of the device. nil if no device was found.
        def find_by_udid(device_udid, mac: false, include_disabled: false)
          all(mac: mac, include_disabled: include_disabled).find do |device|
            device.udid.casecmp(device_udid) == 0
          end
        end

        # @param mac [Bool] Searches for Macs if true
        # @param include_disabled [Bool] Whether to include disable devices. false by default.
        # @return (Device) Find a device based on its name. nil if no device was found.
        def find_by_name(device_name, mac: false, include_disabled: false)
          all(mac: mac, include_disabled: include_disabled).find do |device|
            device.name == device_name
          end
        end

        # Register a new device to this account
        # @param name (String) (required): The name of the new device
        # @param udid (String) (required): The UDID of the new device
        # @param mac (Bool) (optional): Pass Mac if device is a Mac
        # @example
        #   Spaceship.device.create!(name: "Felix Krause's iPhone 6", udid: "4c24a7ee5caaa4847f49aaab2d87483053f53b65")
        # @return (Device): The newly created device
        def create!(name: nil, udid: nil, mac: false)
          # Check whether the user has passed in a UDID and a name
          unless udid && name
            raise "You cannot create a device without a device_id (UDID) and name"
          end

          raise "Device name must be 50 characters or less. \"#{name}\" has a #{name.length} character length." if name.length > 50

          # Find the device by UDID, raise an exception if it already exists
          existing = self.find_by_udid(udid, mac: mac)
          return existing if existing

          # It is valid to have the same name for multiple devices
          device = client.create_device!(name, udid, mac: mac)

          # Update self with the new device
          self.new(device)
        end
      end

      def enabled?
        return self.status == "c"
      end

      def disabled?
        return self.status == "r"
      end

      # Enable current device.
      def enable!
        unless enabled?
          attr = client.enable_device!(self.id, self.udid, mac: self.platform == 'mac')
          initialize(attr)
        end
      end

      # Disable current device. This will invalidate all provisioning profiles that use this device.
      def disable!
        if enabled?
          client.disable_device!(self.id, self.udid, mac: self.platform == 'mac')
          # disable request doesn't return device json, so we assume that the new status is "r" if response succeeded
          self.status = "r"
        end
      end
    end
  end
end
