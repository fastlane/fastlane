module Spaceship
  module Portal
    # Represents a device from the Apple Developer Portal
    class Device < PortalBase
      # @return (String) The ID given from the developer portal. You'll probably not need it.
      # @example
      #   "XJXGVS46MW"
      attr_accessor :id

      # @return (String) The name of the device
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

      # @return (String) Status of the device. Probably always "c"
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
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end

        # <b>DEPRECATED:</b> Use <tt>all_by_platform</tt> instead.
        # @param mac [Bool] Fetches Mac devices if true
        # @return (Array) Returns all devices registered for this account
        def all(mac: false)
          puts '`all` is deprecated. Please use `all_by_platform` instead.'.red
          all_by_platform(platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
        end

        # @param platform [String] Fetches devices of a specific platform
        # @return (Array) Returns all devices registered for this account
        def all_by_platform(platform: Spaceship::Portal::App::IOS)
          client.devices_by_platform(platform: platform).map { |device| self.factory(device) }
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
          all_by_platform(platform: Spaceship::Portal::App::MAC)
        end

        # @return (Array) Returns all devices that can be used for iOS profiles (all devices except TVs)
        def all_ios_profile_devices
          all_by_platform.select { |device| device.device_type != "tvOS" }
        end

        # @return (Array) Returns all devices that can be used for iOS profiles (all devices except TVs)
        def all_for_profile_type(profile_type)
          if profile_type.include? "tvOS"
            Spaceship::Device.all_apple_tvs
          else
            Spaceship::Device.all_ios_profile_devices
          end
        end

        # <b>DEPRECATED:</b> Use <tt>find_by_platform</tt> instead.
        # @param mac [Bool] Searches for Macs if true
        # @return (Device) Find a device based on the ID of the device. *Attention*:
        #  This is *not* the UDID. nil if no device was found.
        def find(device_id, mac: false)
          puts '`find` is deprecated. Please use `find_by_platform` instead.'.red
          find_by_platform(device_id, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
        end

        # @param platform [String] Searches for specified platform
        # @return (Device) Find a device based on the ID of the device. *Attention*:
        #  This is *not* the UDID. nil if no device was found.
        def find_by_platform(device_id, platform: Spaceship::Portal::App::IOS)
          all_by_platform(platform: platform).detect do |device|
            device.id == device_id
          end
        end

        # <b>DEPRECATED:</b> Use <tt>find_by_udid_by_platform</tt> instead.
        # @param mac [Bool] Searches for Macs if true
        # @return (Device) Find a device based on the UDID of the device. nil if no device was found.
        def find_by_udid(device_udid, mac: false)
          puts '`find_by_udid` is deprecated. Please use `find_by_udid_by_platform` instead.'.red
          find_by_udid_by_platform(device_udid, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
        end

        # @param platform [String] Searches for specified platform
        # @return (Device) Find a device based on the UDID of the device. nil if no device was found.
        def find_by_udid_by_platform(device_udid, platform: Spaceship::Portal::App::IOS)
          all_by_platform(platform: platform).detect do |device|
            device.udid.casecmp(device_udid) == 0
          end
        end

        # <b>DEPRECATED:</b> Use <tt>find_by_name_by_platform</tt> instead.
        # @param mac [Bool] Searches for Macs if true
        # @return (Device) Find a device based on its name. nil if no device was found.
        def find_by_name(device_name, mac: false)
          puts '`find_by_name` is deprecated. Please use `find_by_name_by_platform` instead.'.red
          find_by_name_by_platform(device_name, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
        end

        # @param platform [String] Searches for specified platform
        # @return (Device) Find a device based on its name. nil if no device was found.
        def find_by_name_by_platform(device_name, platform: Spaceship::Portal::App::IOS)
          all_by_platform(platform: platform).detect do |device|
            device.name == device_name
          end
        end

        # <b>DEPRECATED:</b> Use <tt>create_by_platform!</tt> instead.
        # Register a new device to this account
        # @param name (String) (required): The name of the new device
        # @param udid (String) (required): The UDID of the new device
        # @param mac (Bool) (optional): Pass Mac if device is a Mac
        # @example
        #   Spaceship.device.create!(name: "Felix Krause's iPhone 6", udid: "4c24a7ee5caaa4847f49aaab2d87483053f53b65")
        # @return (Device): The newly created device
        def create!(name: nil, udid: nil, mac: false)
          puts '`create!` is deprecated. Please use `create_by_platform!` instead.'.red
          create_by_platform!(name: name, udid: udid, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
        end

        # Register a new device to this account
        # @param name (String) (required): The name of the new device
        # @param udid (String) (required): The UDID of the new device
        # @param platform (String) (optional): Platform to search for
        # @example
        #   Spaceship.device.create!(name: "Felix Krause's iPhone 6", udid: "4c24a7ee5caaa4847f49aaab2d87483053f53b65")
        # @return (Device): The newly created device
        def create_by_platform!(name: nil, udid: nil, platform: Spaceship::Portal::App::IOS)
          # Check whether the user has passed in a UDID and a name
          unless udid && name
            raise "You cannot create a device without a device_id (UDID) and name"
          end

          # Find the device by UDID, raise an exception if it already exists
          existing = self.find_by_udid_by_platform(udid, platform: platform)
          return existing if existing

          # It is valid to have the same name for multiple devices

          device = client.create_device_by_platform!(name, udid, platform: platform)

          # Update self with the new device
          self.new(device)
        end
      end
    end
  end
end
