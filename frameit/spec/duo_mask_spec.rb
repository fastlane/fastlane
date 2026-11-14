require 'frameit/editor'

describe Frameit::Editor do
  describe "screen masks" do
    let(:source) { './frameit/spec/fixtures/editor/apostrophes.png' }
    let(:template) { 'duo-frame.png' }
    let(:mask_path) { File.join('device_frames', 'mask.png') }
    # ImageMagick commands such as rotate and resize are provided dynamically.
    let(:image) { double("screenshot image", width: 1398, height: 2034) }
    let(:frame) { double("frame") }
    let(:mask) { double("mask") }
    let(:masked_image) { double("masked image") }
    let(:result) { double("result") }
    let(:mask_command) { double('mask composite command') }
    let(:frame_command) { double('frame composite command', compose: nil, geometry: nil) }
    let(:offset) { { "offset" => "+88+80", "width" => 1398, "mask" => "mask.png" } }
    let(:screenshot) { Frameit::Screenshot.new(source, nil, { "force_device_type" => "iphone-duo-outer" }, Frameit::Platform::IOS) }

    before do
      allow(MiniMagick::Image).to receive(:open).with(source).and_return(image)
      allow(MiniMagick::Image).to receive(:open).with(template).and_return(frame)
      allow(MiniMagick::Image).to receive(:open).with(mask_path).and_return(mask)
      allow(Frameit::TemplateFinder).to receive(:get_template).and_return(template)
      allow(Frameit::FrameDownloader).to receive(:templates_path).and_return('device_frames')
      allow(Frameit::Offsets).to receive(:image_offset).and_return(offset)
      allow(File).to receive(:file?).and_call_original
      allow(File).to receive(:file?).with(mask_path).and_return(true)
      allow(image).to receive(:rotate)
      allow(frame).to receive(:rotate)
      allow(result).to receive(:rotate)
      allow(result).to receive(:format)
      allow(result).to receive(:write)
    end

    it "resizes and applies the screen mask before placing the screenshot behind the bezel" do
      expect(mask).to receive(:resize).with('1398x2034!').ordered
      expect(image).to receive(:composite).with(mask, 'png').ordered.and_yield(mask_command).and_return(masked_image)
      expect(mask_command).to receive(:compose).with('CopyOpacity').ordered
      expect(frame).to receive(:composite).with(masked_image, 'png').ordered.and_yield(frame_command).and_return(result)
      expect(frame_command).to receive(:compose).with('DstOver')
      expect(frame_command).to receive(:geometry).with('+88+80')
      expect(result).to receive(:write).with(screenshot.output_path)

      described_class.new(screenshot, {}).frame!
    end

    it "normalizes landscape orientation before applying the portrait screen mask" do
      allow(screenshot).to receive(:landscape_right?).and_return(true)
      expect(image).to receive(:rotate).with(-90).ordered
      expect(mask).to receive(:resize).with('1398x2034!').ordered
      expect(image).to receive(:composite).with(mask, 'png').ordered.and_yield(mask_command).and_return(masked_image)
      expect(mask_command).to receive(:compose).with('CopyOpacity')
      expect(frame).to receive(:composite).with(masked_image, 'png').ordered.and_yield(frame_command).and_return(result)
      expect(result).to receive(:rotate).with(90).ordered

      described_class.new(screenshot, {}).frame!
    end

    it "keeps the existing composition unchanged when no screen mask is configured" do
      offset.delete('mask')
      expect(MiniMagick::Image).not_to receive(:open).with(mask_path)
      expect(image).not_to receive(:composite)
      expect(frame).to receive(:composite).with(image, 'png').and_yield(frame_command).and_return(result)

      described_class.new(screenshot, {}).frame!
    end

    it "reports a missing mask before compositing the screenshot" do
      allow(File).to receive(:file?).with(mask_path).and_return(false)
      expect(image).not_to receive(:composite)
      expect(frame).not_to receive(:composite)

      expect { described_class.new(screenshot, {}).frame! }.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not find screen mask '#{mask_path}'")
    end
  end
end
