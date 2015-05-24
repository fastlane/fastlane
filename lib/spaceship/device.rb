module Spaceship
  class Device < Base

    attr_accessor :id, :name, :udid, :platform, :status
    attr_mapping({
      'deviceId' => :id,
      'name' => :name,
      'deviceNumber' => :udid,
      'devicePlatform' => :platform,
      'status' => :status
    })

    class << self
      def factory(attrs)
        self.new(attrs)
      end

      def all
        client.devices.map {|device| self.factory(device)}
      end
      def find(device_id)
        all.find do |device|
          device.id == device_id
        end
      end

      def create!(device_udid, device_name)

        # Check whether the user has passed in a UDID and a name
        if not device_udid or not device_name
          raise "You cannot create a device without a device_id (UDID) and device_name"
        end

        # Attempt to find the device if already existing
        device = self.find(device_udid)

        # If the device is nil, create it
        if not device
          device = client.create_device(device_name, device_udid)
          puts device.body
        end

        # Update self with the new device
        self.new(device)
      end
    end
  end
end
