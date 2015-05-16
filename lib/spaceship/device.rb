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
      def all
        client.devices.map {|device| self.new(device)}
      end

      def find(device_id)
        all.find do |device|
          device.id == device_id
        end
      end
    end
  end
end
