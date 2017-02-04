describe Fastlane::Actions::EnsureXcodeVersionAction do
  describe "matching versions" do
    let(:different_response) { "Xcode 7.3\nBuild version 34a893" }
    let(:matching_response) { "Xcode 8.0\nBuild version 8A218a" }
    let(:matching_response_extra_output) { "Couldn't verify that spaceship is up to date\nXcode 8.0\nBuild version 8A218a" }

    it "is successful when the version matches" do
      expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response)
      expect(UI).to receive(:success).with(/Driving the lane/)
      expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

      result = Fastlane::FastFile.new.parse("lane :test do
        ensure_xcode_version(version: '8.0')
      end").runner.execute(:test)
    end

    it "matches even when there is extra output" do
      expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response_extra_output)
      expect(UI).to receive(:success).with(/Driving the lane/)
      expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

      result = Fastlane::FastFile.new.parse("lane :test do
        ensure_xcode_version(version: '8.0')
      end").runner.execute(:test)
    end

    it "presents an error when the version does not match" do
      expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(different_response)
      expect(UI).to receive(:user_error!)

      result = Fastlane::FastFile.new.parse("lane :test do
        ensure_xcode_version(version: '8.0')
      end").runner.execute(:test)
    end
  end
end
