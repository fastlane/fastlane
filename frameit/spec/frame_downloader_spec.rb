require 'frameit/frame_downloader'
require 'tmpdir'

describe Frameit::FrameDownloader do
  describe "#download_frames" do
    let(:downloader) { described_class.new }

    around do |example|
      Dir.mktmpdir do |dir|
        @root = dir
        example.run
      end
    end

    def serve(files)
      templates = File.join(@root, "frames")
      allow(described_class).to receive(:templates_path).and_return(templates)
      responses = { "version.txt" => "3", "files.json" => files.to_json, "offsets.json" => "{}" }
      allow(downloader).to receive(:download_file) { |path, **_| responses.fetch(path, "PNG") }
      templates
    end

    it "writes the listed frames into the templates folder" do
      templates = serve(["Apple iPhone 15 Black.png"])

      downloader.download_frames

      expect(File.read(File.join(templates, "Apple iPhone 15 Black.png"))).to eq("PNG")
    end

    it "refuses names that would write outside the templates folder" do
      ["../escaped.png", "..", "sub/frame.png", "..\\escaped.png"].each do |name|
        serve([name])

        expect { downloader.download_frames }.to raise_error(FastlaneCore::Interface::FastlaneError, /Unexpected frame file name/)
      end

      expect(File.exist?(File.join(@root, "escaped.png"))).to be(false)
    end
  end
end
