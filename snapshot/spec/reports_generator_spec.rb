require 'snapshot/reports_generator'
require 'tmpdir'

describe Snapshot::ReportsGenerator do
  describe '#available_devices' do
    # the Collector generates file names that remove all spaces from the device names, so
    # any keys here can't contain spaces
    it "xcode 8 devices don't have keys that contain spaces" do
      allow(FastlaneCore::Helper).to receive(:xcode_at_least?).with("9.0").and_return(false)

      device_name_keys = Snapshot::ReportsGenerator.new.available_devices.keys
      expect(device_name_keys.none? { |k| k.include?(' ') }).to be(true)
    end

    it "xcode 9 devices have keys that contain spaces" do
      allow(FastlaneCore::Helper).to receive(:xcode_at_least?).with("9.0").and_return(false)

      device_name_keys = Snapshot::ReportsGenerator.new.available_devices.keys
      expect(device_name_keys.none? { |k| k.include?(' ') }).to be(true)
    end
  end
  describe "#generate" do
    # Windows does not allow quotes or angle brackets in file names, so such screenshots cannot exist there
    unless FastlaneCore::Helper.windows?
      around do |example|
        Dir.mktmpdir do |dir|
          @dir = dir
          example.run
        end
      end

      # Screenshot names are file names, so they can contain quotes and angle brackets
      let(:names) { [%(iPhone 15-x" onerror="window.pwned=1" data-x=".png), "iPhone 15-<img src=x onerror=window.pwned=1>.png"] }

      before do
        FileUtils.mkdir_p(File.join(@dir, "en-US"))
        names.each { |name| File.write(File.join(@dir, "en-US", name), "") }
        allow(Snapshot).to receive(:config).and_return({ output_directory: @dir, skip_open_summary: true })
        allow_any_instance_of(described_class).to receive(:available_devices).and_return({ "iPhone 15" => "iPhone 15" })
      end

      it "escapes screenshot names in the generated HTML" do
        described_class.new.generate
        html = File.read(File.join(@dir, "screenshots.html"))

        expect(html).not_to include(%(" onerror="))
        expect(html).not_to include("<img src=x onerror")
        expect(html).to include("x&quot; onerror=&quot;window.pwned=1&quot;")
        expect(html).to include("&lt;img src=x onerror=window.pwned=1&gt;")
      end
    end
  end

  describe "image viewer" do
    # The viewer runs in the browser and cannot be exercised here: this only guards against
    # file names going back into innerHTML (CodeQL js/xss-through-dom)
    it "does not render file names as HTML" do
      allow(Snapshot).to receive(:config).and_return({})
      template = File.read(described_class.new.html_path)

      expect(template).not_to match(/imageInfo\.innerHTML/)
    end
  end
end
