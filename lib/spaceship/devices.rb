module Spaceship
  class Devices
    include Enumerable
    extend Forwardable

    attr_reader :client
    def_delegators :@devices, :each, :first, :last

    Device = Struct.new(:id, :name, :udid, :platform, :status)

    def initialize(client)
      @client = client
      @devices = client.devices.map do |device|
        values = device.values_at('deviceId', 'name', 'deviceNumber', 'devicePlatform', 'status')
        Device.new(*values)
      end
    end

    def find(device_id)
      @devices.find do |device|
        device.id == device_id
      end
    end
    alias [] find
  end
end
