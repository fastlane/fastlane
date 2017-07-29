describe Fastlane do
  describe Fastlane::CommandLineHandler do
    it "properly handles default calls" do
      expect(Fastlane::LaneManager).to receive(:cruise_lane).with("ios", "deploy", {}, nil)
      Fastlane::CommandLineHandler.handle(["ios", "deploy"], {})
    end

    it "properly handles calls with custom parameters" do
      expect(Fastlane::LaneManager).to receive(:cruise_lane).with("ios", "deploy",
                                                                  { key: "value", build_number: '123' },
                                                                  nil)
      Fastlane::CommandLineHandler.handle(["ios", "deploy", "key:value", "build_number:123"], {})
    end

    it "properly converts boolean values to real boolean variables" do
      expect(Fastlane::LaneManager).to receive(:cruise_lane).with("ios", "deploy",
                                                                  { key: true, key2: false },
                                                                  nil)
      Fastlane::CommandLineHandler.handle(["ios", "deploy", "key:true", "key2:false"], {})
    end
  end
end
