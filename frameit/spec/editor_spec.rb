require 'frameit/config_parser'

describe Frameit do
  describe Frameit::Editor do
    before do
      Frameit.config = {}
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
        screenshot_path = './frameit/spec/fixtures/editor/no_ignore.png'
        config = Frameit::ConfigParser.new.load('./frameit/spec/fixtures/editor/Framefile.json').fetch_value(screenshot_path)
        screenshot = Frameit::Screenshot.new(screenshot_path, Frameit::Color::BLACK, config, nil)
        skip = Frameit::Editor.new(screenshot, config).should_skip?
        expect(skip).to be(false)
      end
    end
  end
end
