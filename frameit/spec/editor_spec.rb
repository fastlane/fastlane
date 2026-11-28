require 'frameit/config_parser'

describe Frameit do
  describe Frameit::Editor do
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
        screenshot_path = './frameit/spec/fixtures/editor/apostrophes.png'
        config = Frameit::ConfigParser.new.load('./frameit/spec/fixtures/editor/Framefile.json').fetch_value(screenshot_path)
        screenshot = Frameit::Screenshot.new(screenshot_path, Frameit::Color::BLACK, config, nil)
        Frameit::Editor.new(screenshot, config).frame!
      end

      it "does not double escape apostrophes" do
        expect_any_instance_of(MiniMagick::Tool::Mogrify).to receive(:draw).with("text 0,0 'Don\\'t forget the apostrophes'")
        screenshot_path = './frameit/spec/fixtures/editor/escaped-apostrophes.png'
        config = Frameit::ConfigParser.new.load('./frameit/spec/fixtures/editor/Framefile.json').fetch_value(screenshot_path)
        screenshot = Frameit::Screenshot.new(screenshot_path, Frameit::Color::BLACK, config, nil)
        Frameit::Editor.new(screenshot, config).frame!
      end

      # Every ImageMagick call reads and writes the whole image, so framing
      # should not make the calls that leave the image as it is
      describe "ImageMagick passes" do
        let(:mogrify_args) { [] }

        before do
          allow_any_instance_of(MiniMagick::Tool::Mogrify).to receive(:call) do |tool|
            mogrify_args << tool.args.dup
            ''
          end
          allow_any_instance_of(MiniMagick::Image).to receive(:composite) do |instance, *_args, &block|
            block&.call(double('composite command').as_null_object)
            instance
          end
          allow_any_instance_of(MiniMagick::Image).to receive(:[]).with("%[colorspace]").and_return("sRGB")
          allow_any_instance_of(MiniMagick::Image).to receive(:data).and_return({ "colorspace" => "sRGB" })
        end

        def frame_screenshot
          screenshot_path = './frameit/spec/fixtures/editor/apostrophes.png'
          config = Frameit::ConfigParser.new.load('./frameit/spec/fixtures/editor/Framefile.json').fetch_value(screenshot_path)
          screenshot = Frameit::Screenshot.new(screenshot_path, Frameit::Color::BLACK, config, nil)
          Frameit::Editor.new(screenshot, config).frame!
        end

        it "does not rotate a portrait screenshot or its frame" do
          frame_screenshot
          expect(mogrify_args).not_to be_empty
          expect(mogrify_args.flatten).not_to include("-rotate")
        end

        it "sizes the text canvas in the pass that draws the text" do
          frame_screenshot
          text_passes = mogrify_args.select { |args| args.include?("-draw") }
          expect(text_passes).not_to be_empty
          expect(text_passes).to all(include("-resize"))
        end

        it "reads the colorspace without having ImageMagick describe the whole image" do
          expect_any_instance_of(MiniMagick::Image).not_to receive(:data)
          frame_screenshot
        end
      end
    end

    describe "should_skip?" do
      it "returns true with no matching filter in Framefile.json" do
        screenshot_path = './frameit/spec/fixtures/editor/ignore.png'
        config = Frameit::ConfigParser.new.load('./frameit/spec/fixtures/editor/Framefile.json').fetch_value(screenshot_path)
        screenshot = Frameit::Screenshot.new(screenshot_path, Frameit::Color::BLACK, config, nil)
        skip = Frameit::Editor.new(screenshot, config).should_skip?
        expect(skip).to be(true)
      end
      it "returns false with matching filter in Framefile.json" do
        screenshot_path = './frameit/spec/fixtures/editor/apostrophes.png'
        config = Frameit::ConfigParser.new.load('./frameit/spec/fixtures/editor/Framefile.json').fetch_value(screenshot_path)
        screenshot = Frameit::Screenshot.new(screenshot_path, Frameit::Color::BLACK, config, nil)
        skip = Frameit::Editor.new(screenshot, config).should_skip?
        expect(skip).to be(false)
      end
    end

    describe "fetch_text" do
      context ".strings" do
        it "fetches strings from ../" do
          screenshot_path = './frameit/spec/fixtures/editor/android/en-US/images/phoneScreenshots/screen1.png'
          config = Frameit::ConfigParser.new.load('./frameit/spec/fixtures/editor/Framefile.json').fetch_value(screenshot_path)
          screenshot = Frameit::Screenshot.new(screenshot_path, Frameit::Color::BLACK, config, nil)
          editor = Frameit::Editor.new(screenshot, config)

          # Suppress type validation error
          allow(Fastlane::UI).to receive(:user_error!)

          expect(Frameit::StringsParser).to receive(:parse).and_call_original

          text = editor.send("fetch_text", "title-same-dir")
          expect(text).to eq("Screen1 Title - same dir")
        end

        it "fetches strings from ../../" do
          screenshot_path = './frameit/spec/fixtures/editor/android/en-US/images/phoneScreenshots/screen1.png'
          config = Frameit::ConfigParser.new.load('./frameit/spec/fixtures/editor/Framefile.json').fetch_value(screenshot_path)
          screenshot = Frameit::Screenshot.new(screenshot_path, Frameit::Color::BLACK, config, nil)
          editor = Frameit::Editor.new(screenshot, config)

          # Suppress type validation error
          allow(Fastlane::UI).to receive(:user_error!)

          expect(Frameit::StringsParser).to receive(:parse).and_call_original

          text = editor.send("fetch_text", "title-1-up")
          expect(text).to eq("Screen1 Title - 1 dir up")
        end

        it "fetches strings from ../../../" do
          screenshot_path = './frameit/spec/fixtures/editor/android/en-US/images/phoneScreenshots/screen1.png'
          config = Frameit::ConfigParser.new.load('./frameit/spec/fixtures/editor/Framefile.json').fetch_value(screenshot_path)
          screenshot = Frameit::Screenshot.new(screenshot_path, Frameit::Color::BLACK, config, nil)
          editor = Frameit::Editor.new(screenshot, config)

          # Suppress type validation error
          allow(Fastlane::UI).to receive(:user_error!)

          expect(Frameit::StringsParser).to receive(:parse).and_call_original

          text = editor.send("fetch_text", "title-2-up")
          expect(text).to eq("Screen1 Title - 2 dir up")
        end
      end
    end
  end
end
