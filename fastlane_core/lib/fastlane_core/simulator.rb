require 'open3'

module FastlaneCore
  class Simulator
    class << self
      def requested_os_type
        'iOS'
      end

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
          next if line =~ /^== /
          if line =~ /^-- /
            (os_type, os_version) = line.gsub(/-- (.*) --/, '\1').split
          else
            # iPad 2 (0EDE6AFC-3767-425A-9658-AAA30A60F212) (Shutdown)
            # iPad Air 2 (4F3B8059-03FD-4D72-99C0-6E9BBEE2A9CE) (Shutdown) (unavailable, device type profile not found)
            match = line.match(/\s+([^\(]+) \(([-0-9A-F]+)\) \(([^\(]+)\)(.*unavailable.*)?/)
            if match && !match[4] && os_type == requested_os_type
              @devices << Device.new(name: match[1], os_version: os_version, udid: match[2], state: match[3])
            end
          end
        end

        return @devices
      end

      def clear_cache
        @devices = nil
      end

      # Reset all simulators of this type
      def reset_all
        all.each(&:reset)
      end

      # Reset simulator by UDID or name and OS version
      # Latter is useful when combined with -destination option of xcodebuild
      def reset(udid: nil, name: nil, os_version: nil)
        match = all.detect { |device| device.udid == udid || device.name == name && device.os_version == os_version }
        match.reset if match
      end

      # The code below works from Xcode 7 on
      # def all
      #   Helper.log.info "Fetching available devices" if $verbose

      #   @devices = []
      #   output = ''
      #   Open3.popen3('xcrun simctl list devices --json') do |stdin, stdout, stderr, wait_thr|
      #     output = stdout.read
      #   end

      #   begin
      #     data = JSON.parse(output)
      #   rescue => ex
      #     Helper.log.error ex
      #     Helper.log.error "xcrun simctl CLI broken, run `xcrun simctl list devices` and make sure it works".red
      #     raise "xcrun simctl not working.".red
      #   end

      #   data["devices"].each do |os_version, l|
      #     l.each do |device|
      #       next if device['availability'].include?("unavailable")
      #       next unless os_version.include?(requested_os_type)

      #       os = os_version.gsub(requested_os_type + " ", "").strip
      #       @devices << Device.new(name: device['name'], os_version: os, udid: device['udid'])
      #     end
      #   end

      #   return @devices
      # end
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
      attr_accessor :os_version
      attr_accessor :ios_version # Preserved for backwards compatibility
      attr_accessor :state

      def initialize(name: nil, udid: nil, os_version: nil, state: nil)
        self.name = name
        self.udid = udid
        self.os_version = os_version
        self.ios_version = os_version
        self.state = state
      end

      def to_s
        self.name
      end

      def reset
        Helper.log.info "Resetting #{self}"
        `xcrun simctl shutdown #{self.udid}` if self.state == "Booted"
        `xcrun simctl erase #{self.udid}`
        return
      end
    end
  end

  class SimulatorTV < Simulator
    class << self
      def requested_os_type
        'tvOS'
      end
    end
  end

  class SimulatorWatch < Simulator
    class << self
      def requested_os_type
        'watchOS'
      end
    end
  end
end
