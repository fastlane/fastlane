describe Fastlane::Actions::EnsureXcodeVersionAction do
  describe "matching versions" do
    it "matches" do
      expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return("Xcode 8.0")
      expect(UI).to receive(:success).with(/Driving the lane/)
      expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

      result = Fastlane::FastFile.new.parse("lane :test do
        ensure_xcode_version(version: '8.0')
      end").runner.execute(:test)
    end

    it "doesn't match" do
      expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return("Xcode 7.3")
      expect(UI).to receive(:user_error!)

      result = Fastlane::FastFile.new.parse("lane :test do
        ensure_xcode_version(version: '8.0')
      end").runner.execute(:test)
    end
  end
end
