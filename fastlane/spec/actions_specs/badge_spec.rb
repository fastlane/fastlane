describe Fastlane::Actions::BadgeAction do
  describe "requirements" do
    it "requires ImageMagick to be installed" do
      # Mock out the call to verify that the badge gem is actually installed
      # for the test, since CI won't have it installed, and that's not what
      # we're trying to test here.
      allow(Fastlane::Actions).to receive(:verify_gem!).with('badge').and_return(true)
      # Force the expected command to not be found
      expect(Fastlane::Actions::BadgeAction).to receive(:`).with('which convert').and_return('')

      expect do
        Fastlane::FastFile.new.parse("lane :test do
          badge(dark: true)
        end").runner.execute(:test)
      end.to raise_error(/Install ImageMagick/)
    end
  end

  describe '#check_imagemagick!' do
    it "does nothing if ImageMagick is installed" do
      expect(Fastlane::Actions::BadgeAction).to receive(:`).with('which convert').and_return('/usr/local/bin/convert')

      Fastlane::Actions::BadgeAction.send(:check_imagemagick!)
    end

    it "raises an error if ImageMagick is not installed" do
      expect(Fastlane::Actions::BadgeAction).to receive(:`).with('which convert').and_return('')

      expect do
        Fastlane::Actions::BadgeAction.send(:check_imagemagick!)
      end.to raise_error(/Install ImageMagick/)
    end
  end
end
