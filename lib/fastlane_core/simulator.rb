require 'open3'

module FastlaneCore
  class Simulator
    class << self
      def all
        Helper.log.info "Fetching available devices" if $verbose

        @devices = []
        output = ''
        Open3.popen3('xcrun simctl list devices --json') do |stdin, stdout, stderr, wait_thr|
          output = stdout.read
        end

        begin
          data = JSON.parse(output)
        rescue => ex
          Helper.log.error ex
          Helper.log.error "xcrun simctl CLI broken, run `xcrun simctl list devices` and make sure it works".red
          raise "xcrun simctl not working.".red
        end

        data["devices"].each do |ios_version, l|
          l.each do |device|
            next if device['availability'].include?("unavailable")
            next unless ios_version.include?("iOS")

            os = ios_version.gsub("iOS ", "").strip
            @devices << Device.new(name: device['name'], ios_version: os, udid: device['udid'])
          end
        end

        return @devices
      end

      def clear_cache
        @devices = nil
      end
    end

    # Use the UDID for the given device when setting the destination
    # Why? Because we might get this error message
    # > The requested device could not be found because multiple devices matched the request.
    #
    # This happens when you have multiple simulators for a given device type / iOS combination
    #   { platform:iOS Simulator, id:1685B071-AFB2-4DC1-BE29-8370BA4A6EBD, OS:9.0, name:iPhone 5 }
    #   { platform:iOS Simulator, id:A141F23B-96B3-491A-8949-813B376C28A7, OS:9.0, name:iPhone 5 }
    #
    # We don't want to deal with that, so we just use the UDID

    class Device
      attr_accessor :name

      attr_accessor :udid

      attr_accessor :ios_version

      def initialize(name: nil, udid: nil, ios_version: nil)
        self.name = name
        self.udid = udid
        self.ios_version = ios_version
      end

      def to_s
        self.name
      end
    end
  end
end
