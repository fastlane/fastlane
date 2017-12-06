describe Frameit do
  describe Frameit::Screenshot do
    describe "frame!" do
      before do
        allow_any_instance_of(MiniMagick::Tool::Mogrify).to receive(:call) { '' }
        allow(MiniMagick::Image).to receive(:open) { |path| MiniMagick::Image.new(path) }
        allow_any_instance_of(MiniMagick::Image).to receive(:height) { 1334 }
        allow_any_instance_of(MiniMagick::Image).to receive(:width) { 750 }
        allow_any_instance_of(MiniMagick::Image).to receive(:composite) { |instance| instance }
        allow_any_instance_of(MiniMagick::Image).to receive(:format) {}
        allow_any_instance_of(MiniMagick::Image).to receive(:write) {}
        allow_any_instance_of(MiniMagick::Image).to receive(:identify).and_return("0x0+0+0")

        expect(Frameit::Offsets).to receive(:image_offset).and_return({
          "offset" => "+60+225",
          "width" => 752
        })

        Frameit.config = {}
      end

      it "properly frame screenshots with captions that include apostrophes" do
        expect_any_instance_of(MiniMagick::Tool::Mogrify).to receive(:draw).with("text 0,0 'Don\\'t forget the apostrophes'")
        Frameit::Screenshot.new('./frameit/spec/fixtures/editor/apostrophes.png', Frameit::Color::BLACK).frame!
      end

      it "does not double escape apostrophes" do
        expect_any_instance_of(MiniMagick::Tool::Mogrify).to receive(:draw).with("text 0,0 'Don\\'t forget the apostrophes'")
        Frameit::Screenshot.new('./frameit/spec/fixtures/editor/escaped-apostrophes.png', Frameit::Color::BLACK).frame!
      end
    end
  end
end
