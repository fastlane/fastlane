require 'open3'

module FastlaneCore
  class Simulator
    class << self
      def all
        Helper.log.info "Fetching available devices" if $verbose

        @devices = []
        os_type = 'unknown'
        os_version = 'unknown'
        output = ''
        Open3.popen3('xcrun simctl list devices') do |stdin, stdout, stderr, wait_thr|
          output = stdout.read
        end

        unless output.include?("== Devices ==")
          Helper.log.error "xcrun simctl CLI broken, run `xcrun simctl list devices` and make sure it works".red
          raise "xcrun simctl not working.".red
        end

        output.split(/\n/).each do |line|
          next if line.match(/^== /)
          if line.match(/^-- /)
            (os_type, os_version) = line.gsub(/-- (.*) --/, '\1').split
          else
            # iPad 2 (0EDE6AFC-3767-425A-9658-AAA30A60F212) (Shutdown)
            # iPad Air 2 (4F3B8059-03FD-4D72-99C0-6E9BBEE2A9CE) (Shutdown) (unavailable, device type profile not found)
            match = line.match(/\s+([^\(]+) \(([-0-9A-F]+)\) \((?:[^\(]+)\)(.*unavailable.*)?/)
            if match && !match[3] && os_type == 'iOS'
              @devices << Device.new(name: match[1], ios_version: os_version, udid: match[2])
            end
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
