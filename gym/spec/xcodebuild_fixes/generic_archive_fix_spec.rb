describe Gym do
  describe Gym::XcodebuildFixes do
    let(:watch_app) { 'gym/spec/fixtures/xcodebuild_fixes/ios_watch_app.app' }
    let(:ios_app) { 'gym/spec/fixtures/xcodebuild_fixes/ios_app.app' }

    it "can detect watch application", requires_plistbuddy: true do
      expect(Gym::XcodebuildFixes.is_watchkit_app?(watch_app)).to eq(true)
    end

    it "doesn't detect iOS application" do
      expect(Gym::XcodebuildFixes.is_watchkit_app?(ios_app)).to eq(false)
    end
  end
end
