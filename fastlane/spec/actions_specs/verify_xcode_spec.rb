describe Fastlane::Actions::VerifyXcodeAction do
  describe 'codesign verification' do
    it "reports success for AppStore codesign details" do
      fixture_data = File.read('./fastlane/spec/fixtures/verify_xcode/xcode_codesign_appstore.txt')

      allow(FastlaneCore::UI).to receive(:message)
      expect(Fastlane::Actions).to receive(:sh).with(/codesign/).and_return(fixture_data)
      expect(FastlaneCore::UI).to receive(:success).with(/Successfully verified/)

      Fastlane::Actions::VerifyXcodeAction.verify_codesign({ xcode_path: '' })
    end

    it "reports success for developer.apple.com pre-Xcode 8 codesign details" do
      fixture_data = File.read('./fastlane/spec/fixtures/verify_xcode/xcode7_codesign_developer_portal.txt')

      allow(FastlaneCore::UI).to receive(:message)
      expect(Fastlane::Actions).to receive(:sh).with(/codesign/).and_return(fixture_data)
      expect(FastlaneCore::UI).to receive(:success).with(/Successfully verified/)

      Fastlane::Actions::VerifyXcodeAction.verify_codesign({ xcode_path: '' })
    end

    it "reports success for developer.apple.com post-Xcode 8 codesign details" do
      fixture_data = File.read('./fastlane/spec/fixtures/verify_xcode/xcode8_codesign_developer_portal.txt')

      allow(FastlaneCore::UI).to receive(:message)
      expect(Fastlane::Actions).to receive(:sh).with(/codesign/).and_return(fixture_data)
      expect(FastlaneCore::UI).to receive(:success).with(/Successfully verified/)

      Fastlane::Actions::VerifyXcodeAction.verify_codesign({ xcode_path: '' })
    end

    it "raises an error for invalid codesign details" do
      fixture_data = File.read('./fastlane/spec/fixtures/verify_xcode/xcode_codesign_invalid.txt')

      allow(FastlaneCore::UI).to receive(:message)
      allow(FastlaneCore::UI).to receive(:error)
      expect(Fastlane::Actions).to receive(:sh).with(/codesign/).and_return(fixture_data)

      expect do
        Fastlane::Actions::VerifyXcodeAction.verify_codesign({ xcode_path: '' })
      end.to raise_error(FastlaneCore::Interface::FastlaneError)
    end
  end
end
