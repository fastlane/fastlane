describe Frameit::MacEditor do
  let(:screenshot_path) { './frameit/spec/fixtures/editor/apostrophes.png' }
  let(:config) { { "background" => "./frameit/spec/fixtures/background.jpg", "padding" => 50 } }

  before do
    allow(FastImage).to receive(:size).and_call_original
    allow(FastImage).to receive(:size).with(screenshot_path).and_return([2880, 1800])
    allow(MiniMagick::Image).to receive(:open) { |path| MiniMagick::Image.new(path) }
    allow_any_instance_of(MiniMagick::Tool::Mogrify).to receive(:call) { '' }
    allow_any_instance_of(MiniMagick::Image).to receive(:composite) { |instance| instance }
    allow_any_instance_of(MiniMagick::Image).to receive(:format)
    allow_any_instance_of(MiniMagick::Image).to receive(:write)
    allow(Frameit::Offsets).to receive(:image_offset).and_return({ "offset" => "+380+128", "width" => 2304 })
    Frameit.config = {}
  end

  it "detects a Mac screenshot" do
    expect(Frameit::Screenshot.new(screenshot_path, nil, config, Frameit::Platform::IOS).mac?).to be(true)
  end

  it "puts a Mac screenshot onto the configured background" do
    screenshot = Frameit::Screenshot.new(screenshot_path, nil, config, Frameit::Platform::IOS)
    expect(MiniMagick::Image).to receive(:open).with("./frameit/spec/fixtures/background.jpg")

    Frameit::MacEditor.new(screenshot, config).frame!
  end
end
