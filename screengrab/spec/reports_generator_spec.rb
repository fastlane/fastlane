require 'screengrab/reports_generator'
require 'tmpdir'

describe Screengrab::ReportsGenerator do
  describe "#generate" do
    # Windows does not allow quotes in file names, so such screenshots cannot exist there
    unless FastlaneCore::Helper.windows?
      around do |example|
        Dir.mktmpdir do |dir|
          @dir = dir
          example.run
        end
      end

      before do
        folder = File.join(@dir, "en-US", "images", "phoneScreenshots")
        FileUtils.mkdir_p(folder)
        # Screenshot names are file names, so they can contain quotes
        File.write(File.join(folder, %(x" onerror="window.pwned=1" data-x=".png)), "")
        allow(Screengrab).to receive(:config).and_return({ output_directory: @dir, skip_open_summary: true })
      end

      it "escapes screenshot names in the generated HTML" do
        described_class.new.generate
        html = File.read(File.join(@dir, "screenshots.html"))

        expect(html).not_to include(%(" onerror="))
        expect(html).to include("x&quot; onerror=&quot;window.pwned=1&quot;")
      end
    end
  end

  describe "image viewer" do
    # The viewer runs in the browser and cannot be exercised here: this only guards against
    # file names going back into innerHTML (CodeQL js/xss-through-dom)
    it "does not render file names as HTML" do
      template = File.read(File.join(Screengrab::ROOT, "lib", "screengrab/page.html.erb"))

      expect(template).not_to match(/imageInfo\.innerHTML/)
    end
  end
end
