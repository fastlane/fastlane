require_relative '../frames_generator/import_iphone_duo'

describe Frameit::DuoFrameImporter do
  around do |example|
    Dir.mktmpdir("frameit-duo-import-spec") do |directory|
      @source = File.join(directory, "artwork")
      @destination = File.join(directory, "cache")
      FileUtils.mkdir_p(File.join(@source, "PNG"))
      FileUtils.mkdir_p(@destination)
      described_class::SCREENS.each_value do |screen|
        described_class::COLORS.each do |color|
          path = File.join(@source, "PNG", "iPhone Duo - #{color} - #{screen[:source]}.png")
          File.write(path, "artwork #{color} #{screen[:source]}")
        end
      end
      example.run
    end
  end

  def stub_image_processing
    allow(described_class).to receive(:run_magick) do |*args|
      if args.first == "identify"
        screen = described_class::SCREENS.values.find { |value| args.last.include?(value[:source]) }
        screen[:canvas].join(" ")
      else
        File.write(args.last, "screen mask")
        ""
      end
    end
  end

  it "imports both finishes and masks while preserving existing cache files and offsets" do
    stub_image_processing
    offsets_path = File.join(@destination, "offsets.json")
    existing = { "portrait" => { "iPhone 17" => { "offset" => "+1+2", "width" => 1206 } }, "other" => true }
    File.write(offsets_path, JSON.generate(existing))
    File.write(File.join(@destination, "existing.png"), "existing artwork")

    described_class.import(@source, @destination)

    offsets = JSON.parse(File.read(offsets_path))
    expect(offsets["portrait"]["iPhone 17"]).to eq(existing["portrait"]["iPhone 17"])
    expect(offsets["other"]).to be(true)
    expect(File.read(File.join(@destination, "existing.png"))).to eq("existing artwork")
    described_class::SCREENS.each do |name, screen|
      x, y = screen[:origin]
      mask = "Apple iPhone Duo #{name} Screen Mask.png"
      expect(offsets["portrait"]["iPhone Duo #{name}"]).to eq({ "offset" => "+#{x}+#{y}", "width" => screen[:size].first, "mask" => mask })
      expect(File.read(File.join(@destination, mask))).to eq("screen mask")
      described_class::COLORS.each do |color|
        expect(File.read(File.join(@destination, "Apple iPhone Duo #{name} #{color}.png"))).to eq("artwork #{color} #{screen[:source]}")
      end
    end
    expect(described_class).to have_received(:run_magick).with(
      anything, "-alpha", "extract", "-alpha", "off", "-threshold", "0",
      "-fill", "white", "-draw", "color 0,0 floodfill", "-channel", "RGB", "-negate", "+channel", "-alpha", "off",
      "-crop", "1398x2034+88+80", "+repage", anything
    )
  end

  it "accepts a PNG directory directly and can be run again without duplicating entries" do
    stub_image_processing
    2.times { described_class.import(File.join(@source, "PNG"), @destination) }
    offsets = JSON.parse(File.read(File.join(@destination, "offsets.json")))
    expect(offsets["portrait"].keys).to match_array(["iPhone Duo Outer", "iPhone Duo Inner"])
    expect(Dir.glob(File.join(@destination, "*.png")).count).to eq(6)
  end

  it "rejects unexpected artwork dimensions before changing the cache" do
    allow(described_class).to receive(:run_magick).and_return("1 1")
    expect { described_class.import(@source, @destination) }.to raise_error(/Unexpected dimensions/)
    expect(Dir.children(@destination)).to be_empty
  end

  it "leaves the cache unchanged if a required input is missing" do
    stub_image_processing
    missing = File.join(@source, "PNG", "iPhone Duo - Star White - Inner Open Portrait.png")
    FileUtils.rm(missing)
    allow(described_class).to receive(:run_magick).with("identify", "-format", "%w %h", missing).and_raise("ImageMagick failed: missing input")
    expect { described_class.import(@source, @destination) }.to raise_error(/missing input/)
    expect(Dir.children(@destination)).to be_empty
  end

  it "reports an ImageMagick failure" do
    status = instance_double(Process::Status, success?: false)
    allow(Open3).to receive(:capture2e).with("magick", "identify", "missing.png").and_return(["missing input", status])
    expect { described_class.run_magick("identify", "missing.png") }.to raise_error("ImageMagick failed: missing input")
  end
end
