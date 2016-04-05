require 'gym/xcodebuild_fixes/generic_archive_fix'

describe Gym do
  describe Gym::XcodebuildFixes do
    let (:watch_ipa) { 'spec/fixtures/xcodebuild_fixes/watch_app.app/info.plist' }
    let (:ios_ipa) { 'spec/fixtures/xcodebuild_fixes/ios_app.app/info.plist' }

    it "can detect watch application" do
      expect(Gym::XcodebuildFixes.is_watchkit_ipa?(watch_ipa)).to eq(true)
    end

    it "doesn't detect iOS application" do
      expect(Gym::XcodebuildFixes.is_watchkit_ipa?(ios_ipa)).to eq(false)
    end
  end
end
