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

      def find_by_udid(device_udid)
        all.find do |device|
          device.udid == device_udid
        end
      end

      def find_by_name(device_name)
        all.find do |device|
          device.name == device_name
        end
      end

      def create!(device_name, device_udid)

        # Check whether the user has passed in a UDID and a name
        if not device_udid or not device_name
          raise "You cannot create a device without a device_id (UDID) and device_name"
        end

        # Find the device by UDID, raise an exception if it already exists
        if self.find_by_udid(device_udid)
          raise "The device UDID '#{device_udid}' already exists on this team."
        end

        # Find the device by name, raise an exception if it already exists
        if self.find_by_name(device_name)
          raise "The device name '#{device_name}' already exists on this team, use different one."
        end

        device = client.create_device!(device_name, device_udid)

        # Update self with the new device
        self.new(device)
      end
    end
  end
end
