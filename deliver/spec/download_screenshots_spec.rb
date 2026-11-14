require 'deliver/download_screenshots'
require 'tmpdir'

describe Deliver::DownloadScreenshots do
  describe ".download_screenshots" do
    let(:localization) { double("localization", locale: "en-US", get_app_screenshot_sets: [screenshot_set]) }
    let(:screenshot_set) { double("screenshot_set", screenshot_display_type: "APP_IPHONE_65", apple_tv?: false, imessage?: false, app_screenshots: [screenshot]) }
    let(:screenshot) { double("screenshot", file_name: "shot.png", image_asset_url: url) }

    around do |example|
      Dir.mktmpdir do |dir|
        @dir = dir
        example.run
      end
    end

    context "with an https url" do
      let(:url) { "https://is1-ssl.mzstatic.com/image/thumb/shot/1242x2688bb.png" }

      it "writes the downloaded image" do
        stub_request(:get, url).to_return(body: "PNGDATA")

        described_class.download_screenshots(@dir, localization)

        expect(File.binread(File.join(@dir, "en-US", "0_APP_IPHONE_65_0.png"))).to eq("PNGDATA")
      end
    end

    context "with a url that is not http" do
      let(:marker) { File.join(@dir, "command-ran") }
      let(:url) { "|touch #{marker}" }

      it "refuses it without running it as a command" do
        expect do
          described_class.download_screenshots(@dir, localization)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /Unexpected screenshot URL/)

        expect(File.exist?(marker)).to be(false)
      end
    end

    context "with a local path" do
      let(:url) { "/etc/hosts" }

      it "refuses it" do
        expect do
          described_class.download_screenshots(@dir, localization)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /Unexpected screenshot URL/)
      end
    end
  end
end
