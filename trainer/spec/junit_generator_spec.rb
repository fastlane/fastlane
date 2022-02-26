describe Trainer do
  describe Trainer::JunitGenerator do
    it "works for a valid .plist file" do
      tp = Trainer::TestParser.new("./trainer/spec/fixtures/Valid1.plist")
      junit = File.read("./trainer/spec/fixtures/Valid1.junit")
      expect(tp.to_junit).to eq(junit)
    end

    it "works for a valid .plist file and xcpretty naming" do
      tp = Trainer::TestParser.new("./trainer/spec/fixtures/Valid1.plist", { xcpretty_naming: true })
      junit = File.read("./trainer/spec/fixtures/Valid1-x.junit")
      expect(tp.to_junit).to eq(junit)
    end

    it "works for a with all tests passing" do
      tp = Trainer::TestParser.new("./trainer/spec/fixtures/Valid2.plist")
      junit = File.read("./trainer/spec/fixtures/Valid2.junit")
      expect(tp.to_junit).to eq(junit)
    end

    it "works for a with all tests passing and xcpretty naming" do
      tp = Trainer::TestParser.new("./trainer/spec/fixtures/Valid2.plist", { xcpretty_naming: true })
      junit = File.read("./trainer/spec/fixtures/Valid2-x.junit")
      expect(tp.to_junit).to eq(junit)
    end

    it "works with an xcresult", requires_xcode: true do
      tp = Trainer::TestParser.new("./trainer/spec/fixtures/Test.test_result.xcresult")
      junit = File.read("./trainer/spec/fixtures/XCResult.junit")
      expect(tp.to_junit).to eq(junit)
    end
  end
end
