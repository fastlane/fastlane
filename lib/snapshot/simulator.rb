module Snapshot
  class Simulator
    class << self
      def all
        return @devices if @devices
        Helper.log.info "Fetching available devices" if $verbose

        # we do it using open since ` just randomly hangs with instruments -s
        output = ''
        Open3.popen3('instruments -s') do |stdin, stdout, stderr, wait_thr|
          output = stdout.read
        end

        unless output.include?("Known Devices")
          Helper.log.error "Instruments CLI broken, run `instruments -s` and make sure it works".red
          Helper.log.error "The easiest way to fix this is to restart your Mac".red
          raise "Instruments CLI not working...".red
        end

        output = output.split("Known Devices:").last.split("Known Templates:").first
        @devices = []
        output.split("\n").each do |current|
          m = current.match(/(.*) \((.*)\) \[(.*)\]/)
          next unless m
          name = m[1]
          udid = m[3]
          next unless udid.include?("-") # as we want to ignore the real devices

          next if name.include?("iPad") and !name.include?("Retina") # we only need one iPad
          next if name.include?("6s") # same screen resolution
          next if name.include?("5s") # same screen resolution

          @devices << Device.new(name: name, ios_version: m[2], udid: udid)
        end

        return @devices
      end
    end

    # Example Output for `instruments -s`
    #
    #   Known Devices:
    #   Felix [A8B765B9-70D4-5B89-AFF5-EDDAF0BC8AAA]
    #   Felix Krause's iPhone 6 (9.0.1) [2cce6c8deb5ea9a46e19304f4c4e665069ccaaaa]
    #   iPad 2 (9.0) [863234B6-C857-4DF3-9E27-897DEDF26EDA]
    #   iPad Air (9.0) [3827540A-D953-49D3-BC52-B66FC59B085E]
    #   iPad Air 2 (9.0) [6731E2F9-B70A-4102-9B49-6AEFE300F460]
    #   iPad Retina (9.0) [DFEE2E76-DABF-47C6-AA1A-ACF873E57435]
    #   iPhone 4s (9.0) [CDEB0462-9ECD-40C7-9916-B7C44EC10E17]
    #   iPhone 5 (9.0) [1685B071-AFB2-4DC1-BE29-8370BA4A6EBD]
    #   iPhone 5s (9.0) [C60F3E7A-3D0E-407B-8D0A-EDAF033ED626]
    #   iPhone 6 (9.0) [4A822E0C-4873-4F12-B798-8B39613B24CE]
    #   iPhone 6 Plus (9.0) [A522ACFF-7948-4344-8CA8-3F62ED9FFB18]
    #   iPhone 6s (9.0) [C956F5AA-2EA3-4141-B7D2-C5BE6250A60D]
    #   iPhone 6s Plus (9.0) [A3754407-21A3-4A80-9559-3170BB3D50FC]
    #   Known Templates:
    #   "/Applications/Xcode70.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.xrplugin/Contents/Resources/Automation.tracetemplate"
    #   "/Applications/Xcode70.app/Contents/Applications/Instruments.app/Contents/PlugIns/OpenGLESAnalyzerInstrument.xrplugin/Contents/Resources/OpenGL ES Analysis.tracetemplate"
    #   "/Applications/Xcode70.app/Contents/Applications/Instruments.app/Contents/PlugIns/XRMobileDeviceDiscoveryPlugIn.xrplugin/Contents/Resources/Energy Diagnostics.tracetemplate"

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
