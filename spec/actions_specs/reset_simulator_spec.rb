describe Fastlane do
  describe Fastlane::FastFile do
    it "raises an exception when no device name is specified" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          reset_simulator({})
        end").runner.execute(:test)
      end.to raise_error
    end
  end
end
